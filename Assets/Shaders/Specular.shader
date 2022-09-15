// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "MyShaders/Specular"
{
    Properties
    {
        _Color ("Color", Color) = (0, 0, 0, 1)
        _Shininess ("Shininess", Range(0.01, 20)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "LightMode"="ForwardBase" }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityStandardBRDF.cginc"

            uniform float4 _Color;
            uniform float _Shininess;
            
            struct VertexData
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            
            struct Interpolators
            {
                float4 position : SV_POSITION;
                float3 normal : TEXCOORD0;
                float4 ambient : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            Interpolators vert (VertexData v)
            {
                Interpolators i;
                i.position = UnityObjectToClipPos(v.vertex);
                i.normal = UnityObjectToWorldNormal(v.normal);
                i.ambient = float4(max(0, ShadeSH9(float4(i.normal, 1))), 1);
                i.viewDir = normalize(WorldSpaceViewDir(v.vertex));
                return i;
            }

            fixed4 frag (Interpolators i) : SV_Target
            {
                float specular = pow(max(0.0, DotClamped(reflect(-_WorldSpaceLightPos0.xyz, i.normal), i.viewDir)), _Shininess);
                float diffuse = DotClamped(i.normal, _WorldSpaceLightPos0.xyz);
                return _Color * diffuse * _LightColor0 + i.ambient + specular;
            }
            ENDCG
        }
    }
}
