Shader "MyShaders/LitColor"
{
    Properties
    {
        _Color ("Color", Color) = (0, 0, 0, 1)
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
            };

            Interpolators vert (VertexData v)
            {
                Interpolators i;
                i.position = UnityObjectToClipPos(v.vertex);
                i.normal = UnityObjectToWorldNormal(v.normal);
                i.ambient = float4(max(0, ShadeSH9(float4(i.normal, 1))), 1);
                return i;
            }

            fixed4 frag (Interpolators i) : SV_Target
            {
                return _Color * DotClamped(i.normal, _WorldSpaceLightPos0.xyz) * _LightColor0 + i.ambient;
            }
            ENDCG
        }
    }
}
