Shader "Light/Specular Vertex"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", float) = 10
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

            float4 _Diffuse;
            float4 _Specular;
            float _Gloss;

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
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 diffuse = _LightColor0.rgb*_Diffuse.rgb*saturate(dot(normal, lightDir));

                float3 reflectDir = normalize(reflect(-lightDir, normal));
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, i.vertex).xyz);
                float3 specular = _LightColor0.rgb*_Specular.rgb*pow(saturate(dot(viewDir, reflectDir)), _Gloss);

                o.color = diffuse + specular;
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                return fixed4(i.color, 1);
            }

            ENDCG
        }
    }
}