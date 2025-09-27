Shader "Unlit/SphereUnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            //ZTest Greater
            //Cull Front
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                //float3 pos : TEXCOORD1;

                float3 normal : NORMAL;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                //o.pos = v.vertex.xyz;
                o.normal = v.normal.xyz;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                //fixed4 col = fixed4(i.pos.xyz, 1);
                //fixed4 col = fixed4(i.normal.xyz * 0.5 + 0.5, 1);
                fixed4 textColor = tex2D(_MainTex, i.uv);
                float t = i.normal.x*0.5+0.5;//法線のx成分について、0~1に変換
                t = 1- (1 - t) * (1 - t)//テクスチャの色が出やすいようにする
                //fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return lerp(fixed4(1,0,0,1), textColor,t);//法線のxが強いほどテクスチャのカラーを出す
            }
            ENDCG
        }
    }
}
