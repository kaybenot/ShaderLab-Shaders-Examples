Shader "MyShaders/FullyLitTransparentColor"
{
    Properties
    {
        _Color ("Color", Color) = (0, 0, 0, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" "LightMode"="ForwardBase"}
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Back
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
                return fixed4(_Color.xyz + _LightColor0.xyz * DotClamped(i.normal, _WorldSpaceLightPos0.xyz) + i.ambient, _Color.a);
            }
            ENDCG
        }
        
        Tags { "LightMode"="ForwardAdd"}
        Blend One One
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #pragma multi_compile_fwdadd

            #include "UnityStandardBRDF.cginc"
            #include "AutoLight.cginc"

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
                i.normal = UnityObjectToWorldNormal(v.normal);
                i.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return i;
            }

            fixed4 frag (Interpolators i) : SV_Target
            {
                float3 lightDir;
                UNITY_LIGHT_ATTENUATION(attenuation, 0, i.worldPos);
            #if defined(POINT) || defined(POINT_COOKIE) || defined(SPOT)
                lightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
            #else
                lightDir = _WorldSpaceLightPos0.xyz;
            #endif
                
                return fixed4(_Color.xyz + _LightColor0.xyz, _Color.a) * attenuation * DotClamped(i.normal, lightDir);
            }
            ENDCG
        }
    }
}
