Shader "Custom/NewUnlitUniversalRenderPipelineShader1"
{
    Properties
    {
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        _SubColor0("Sub Color0", Color) = (1, 1, 1, 1)
        _SubColor1("Sub Color1", Color) = (1, 1, 1, 1)
        _SubColor2("Sub Color2", Color) = (1, 1, 1, 1)
        [MainTexture] _BaseMap("Base Map", 2D) = "white"
        _LerpRatio0("LerpRatio",Float)=0.5 
        _LerpRatio1("LerpRatio",Float)=0.5 
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            //ZTestのGreaterとLEqualを動的に切り替える処理の検討をしておく→昨年度はUnityのURPの機能で実装に逃げたから
            ZTest LEqual
            Cull Back
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal:NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                float4 _BaseMap_ST;

                half4 _SubColor0;
                half4 _SubColor1;
                half4 _SubColor2;

                float _LerpRatio0;
                float _LerpRatio1;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
                OUT.normal=IN.normal.xyz;
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                //SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap,IN.uv)でテクスチャが反映されるっぽい？
                //それに色をかけたらその色に変化した
                //

                //デフォルト
                //half color=SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap,IN.uv)*_BaseColor;

                //lerp
                half4 color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv) * lerp(lerp(_SubColor2,_SubColor0,IN.normal.x*_LerpRatio0+0.5),lerp(_SubColor1,_BaseColor,IN.normal.x*_LerpRatio1+0.5),IN.normal.y*0.5+0.5);
                
                //法線
                //half4 color=SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap,IN.uv)*half4(IN.normal.xyz*0.5+0.5,1);

                return color;
            }
            ENDHLSL
        }
    }
}
