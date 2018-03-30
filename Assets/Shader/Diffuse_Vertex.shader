Shader "Light/Diffuse Vertex"
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
                float3 color : Color;
            };

            v2f vert(appdata_base i)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(i.vertex);
                float3 normal = normalize(UnityObjectToWorldNormal(i.normal));
                //_WorldSpaceLightPos0:Directional lights
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                //_LightColor0:declared in Lighting.cginc
                float3 diffuse = _LightColor0.rgb*_Color.rgb*saturate(dot(normal, lightDir));
                o.color = diffuse;
                return o;
            }

            float4 frag(v2f i) : SV_TARGET
            {
                return float4(i.color, 1);
            }

            ENDCG
        }
    }
}