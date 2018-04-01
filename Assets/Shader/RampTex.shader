Shader "Light/RampTex"
{
    Properties
    {
        _RampTex ("RampTex", 2D) = "white"{}
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

            sampler2D _RampTex;
            float4 _Diffuse;
            float4 _Specular;
            float _Gloss;

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 normal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float2 uv : TEXCOORD3;
            };

            v2f vert(appdata_base i)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(i.vertex);
                o.normal = UnityObjectToWorldNormal(i.normal);
                o.worldPos = mul(unity_ObjectToWorld, i.vertex);
                o.uv = i.texcoord;
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                fixed3 normal = normalize(i.normal);
                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

                fixed halfLambert = saturate(dot(normal, lightDir))*0.5 + 0.5;
                fixed3 diffuse = tex2D(_RampTex, fixed2(halfLambert, halfLambert))*_LightColor0.rgb*_Diffuse.rgb;

                fixed3 halfDir = normalize(lightDir + viewDir);
                fixed3 specular = _LightColor0.rgb*_Specular.rgb*pow(saturate(dot(normal, halfDir)), _Gloss);

                return fixed4(diffuse + specular, 1);
            }

            ENDCG
        }
    }
}