Shader "Light/BlinnPhong"
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
                float3 normal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            v2f vert(appdata_base i)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(i.vertex);
                o.normal = UnityObjectToWorldNormal(i.normal);
                o.worldPos = mul(unity_ObjectToWorld, i.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                fixed3 normal = normalize(i.normal);
                fixed3 worldPos = i.worldPos;
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                fixed3 diffuse = _LightColor0.rgb*_Diffuse.rgb*saturate(dot(normal, lightDir));

                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - worldPos.xyz);
                fixed3 halfDir = normalize(viewDir + lightDir);
                fixed3 specular = _LightColor0.rgb*_Diffuse.rgb*pow(saturate(dot(halfDir, normal)), _Gloss);

                return fixed4(diffuse + specular, 1);
            }

            ENDCG
        }
    }
}