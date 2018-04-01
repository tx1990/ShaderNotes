// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Light/NormalMap World"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white"{}
        _NormalMap ("NormalMap", 2D) = "white"{}
        _NormalScale ("NormalScale", float) = 1
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
            float4 _Specular;
            float _Gloss;

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 TtoW0 : TEXCOORD1;
                float4 TtoW1 : TEXCOORD2;
                float4 TtoW2 : TEXCOORD3;
            };

            v2f vert(appdata_tan i)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(i.vertex);
                o.uv = i.texcoord;
                float3 worldPos = mul(unity_ObjectToWorld, i.vertex).xyz;
                float3 normal =  UnityObjectToWorldNormal(i.normal);
                float3 tangent = UnityObjectToWorldDir(i.tangent.xyz);
                float3 bitnormal = cross(normal, tangent)*i.tangent.w;
                o.TtoW0 = float4(tangent.x, bitnormal.x, normal.x, worldPos.x);
                o.TtoW1 = float4(tangent.y, bitnormal.y, normal.y, worldPos.y);
                o.TtoW2 = float4(tangent.z, bitnormal.z, normal.z, worldPos.z);
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                fixed3 albedo = tex2D(_MainTex, i.uv);
                float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w); 
                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));  
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));  
                fixed3 normal = UnpackNormal(tex2D(_NormalMap, i.uv));
                normal.xy *= _NormalScale;
                normal.z = sqrt(1 - saturate(dot(normal.xy, normal.xy)));
                normal = normalize(fixed3(dot(i.TtoW0.xyz, normal), dot(i.TtoW1.xyz, normal), dot(i.TtoW2.xyz, normal)));
                fixed3 diffuse = _LightColor0.rgb*saturate(dot(normal, lightDir))*albedo;
                fixed3 halfDir = normalize(lightDir + viewDir);
                fixed3 specular = _LightColor0.rgb*_Specular.rgb*pow(saturate(dot(normal, halfDir)), _Gloss);
                return fixed4(UNITY_LIGHTMODEL_AMBIENT.rgb*albedo + diffuse + specular, 1);
            }

            ENDCG
        }
    }
}