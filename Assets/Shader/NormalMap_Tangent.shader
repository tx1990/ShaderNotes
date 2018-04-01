Shader "Light/NormalMap Tangent"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white"{}
        _NormalMap ("NormalMap", 2D) = "white"{}
        _NormalScale ("NormalScale", float) = 1
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

            sampler2D _MainTex;
            sampler2D _NormalMap;
            float _NormalScale;
            float4 _Diffuse;
            float4 _Specular;
            float _Gloss;

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 lightDir : TEXCOORD0;
                float3 viewDir : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            v2f vert(appdata_tan v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;

                //float3 bitnormal = cross(normalize(v.normal), normalize(v.tangent.xyz))*v.tangent.w;
                //float3x3 rotation = float3x3(v.tangent.xyz, bitnormal, v.normal);
                TANGENT_SPACE_ROTATION;
                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
                o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                fixed3 lightDir = normalize(i.lightDir);
                fixed3 viewDir = normalize(i.viewDir);
                fixed3 albedo = tex2D(_MainTex, i.uv);
                fixed3 normal = UnpackNormal(tex2D(_NormalMap, i.uv));
                normal.xy *= _NormalScale;
                normal.z = sqrt(1 - saturate(dot(normal.xy, normal.xy)));
                fixed3 diffuse = _LightColor0.rgb*saturate(dot(normal, lightDir))*albedo;
                fixed3 halfDir = normalize(lightDir + viewDir);
                fixed3 specular = _LightColor0.rgb*_Specular.rgb*pow(saturate(dot(normal, halfDir)), _Gloss);
                return fixed4(UNITY_LIGHTMODEL_AMBIENT.rgb*albedo + diffuse + specular, 1);
            }

            ENDCG
        }
    }
}