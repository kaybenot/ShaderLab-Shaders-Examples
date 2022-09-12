Shader "MyShaders/VertexLitColor"
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
                float diffuse : TEXCOORD0;
            };

            Interpolators vert (VertexData v)
            {
                Interpolators i;
                i.position = UnityObjectToClipPos(v.vertex);
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                i.diffuse = DotClamped(worldNormal, _WorldSpaceLightPos0.xyz);
                return i;
            }

            fixed4 frag (Interpolators i) : SV_Target
            {
                return _Color * i.diffuse * _LightColor0;
            }
            ENDCG
        }
    }
}
