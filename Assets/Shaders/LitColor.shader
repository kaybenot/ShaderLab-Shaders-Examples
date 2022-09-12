Shader "MyShaders/LitColor"
{
    Properties
    {
        _Color ("Color", Color) = (0, 0, 0, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
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
                float3 normal : TEXCOORD1;
            };

            Interpolators vert (VertexData v)
            {
                Interpolators i;
                i.position = UnityObjectToClipPos(v.vertex);
                i.normal = UnityObjectToWorldNormal(v.normal);
                return i;
            }

            fixed4 frag (Interpolators i) : SV_Target
            {
                return _Color * DotClamped(i.normal, _WorldSpaceLightPos0.xyz) * _LightColor0;
            }
            ENDCG
        }
    }
}
