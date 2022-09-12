Shader "MyShaders/FullyLitColor"
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
        
        Tags { "LightMode"="ForwardAdd" }
        Blend One One
        ZWrite Off
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
                float3 worldPos : TEXCOORD1;
            };

            Interpolators vert (VertexData v)
            {
                Interpolators i;
                i.position = UnityObjectToClipPos(v.vertex);
                i.worldPos = mul(unity_ObjectToWorld, v.vertex);
                i.normal = UnityObjectToWorldNormal(v.normal);
                return i;
            }

            fixed4 frag (Interpolators i) : SV_Target
            {
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
                return _Color * DotClamped(i.normal, lightDir) * _LightColor0;
            }
            ENDCG
        }
    }
}
