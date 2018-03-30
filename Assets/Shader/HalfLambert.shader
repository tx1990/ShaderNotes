Shader "Light/HalfLambert"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
    }

    SubShader
    {
        Pass
        {
            Tags {"LightMode" = "ForwardBase"}

            CGPROGRAM

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            #pragma vertex vert
            #pragma fragment frag

            float4 _Color;

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 normal : TEXCOORD0;
            };

            v2f vert(appdata_base i)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(i.vertex);
                o.normal = normalize(i.normal);
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                float3 normal = normalize(i.normal);
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float diffuse = dot(normal, lightDir)*0.5 + 0.5;
                float3 color = _LightColor0.rgb*_Color.rgb*diffuse;
                return fixed4(color, 1);
            }

            ENDCG
        }
    }
}