Shader "Custom/Cauldron_Shader"
{
    Properties
    {
        _XPeriod("X Period", Float) = 1
        _YPeriod("Y Period", Float) = 1
        [MainTexture] _BaseMap("Base Map", 2D) = "white"
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            ZTest Greater
            Cull Front

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 pos : TEXCOORD1;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                float _XPeriod;
                float _YPeriod;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
                OUT.pos = IN.positionOS.xyz;
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                half x = cos(IN.pos.x * _XPeriod) * 0.5 + 0.5;
                half y = cos(IN.pos.y * _YPeriod) * 0.5 + 0.5;
                
                half4 color = half4(x, y, 1 - max(x, y), 0);
                return color;
            }
            ENDHLSL
        }
    }
}
