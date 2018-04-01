Shader "Alpha/AlphaTest"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white"{}
        _Cutoff ("Cutoff", float) = 0.5
        _Gloss ("Gloss", float) = 20
    }

    SubShader
    {
        Tags {"Queuw" = "AlphaTest" "IgnoreProjector" = "True" "RenderType" = "TransparentCutout"}

        Pass
        {
            Tags {"LightMode" = "ForwardBase"}

            CGPROGRAM

            #include "Lighting.cginc"

            #pragma vertex vert
            #pragma fragment frag

            sampler2D _MainTex;
            float _Cutoff;
            float _Gloss;

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };

            v2f vert(appdata_base i)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(i.vertex);
                o.uv = i.texcoord;
                o.normal = UnityObjectToWorldNormal(i.normal);
                o.worldPos = mul(unity_ObjectToWorld, i.vertex);
                return o;
            }

            fixed3 frag(v2f i) : SV_TARGET
            {
                fixed4 color = tex2D(_MainTex, i.uv);
                clip(color.a - _Cutoff);

                fixed3 normal = normalize(i.normal);
                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

                fixed3 diffuse = _LightColor0.rgb*color.rgb*saturate(dot(normal, lightDir));

                fixed3 halfDir = normalize(lightDir + viewDir);
                fixed3 specular = _LightColor0.rgb*pow(saturate(dot(normal, halfDir)), _Gloss);

                return fixed4(diffuse + specular, 1);
            }

            ENDCG
        }
    }
}