Shader "MyShaders/ToonShader"
{
    Properties
    {
        _Color ("Color", Color) = (0, 0, 0, 1)
        _SemiShadow ("Semi shadow threshold", Range(0.001, 1)) = 0.4
        _SemiShadowColor ("Semi shadow color", Color) = (0, 0, 0, 1)
        _Shadow ("Shadow threshold", Range(0.001, 1)) = 0.7
        _ShadowColor ("Shadow color", Color) = (0, 0, 0, 1)
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
            uniform float _SemiShadow;
            uniform float4 _SemiShadowColor;
            uniform float _Shadow;
            uniform float4 _ShadowColor;
            
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
                float diffuse = DotClamped(i.normal, _WorldSpaceLightPos0.xyz);
                float4 color = diffuse < _SemiShadow ? (diffuse < _Shadow ? _ShadowColor : _SemiShadowColor) : _Color;
                return color * _LightColor0 + i.ambient;
            }
            ENDCG
        }
        
        Tags { "LightMode"="ForwardAdd" }
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
            uniform float _SemiShadow;
            uniform float4 _SemiShadowColor;
            uniform float _Shadow;
            uniform float4 _ShadowColor;
            
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
                lightDir = _WorldSpaceLightPos0.xyz - i.worldPos;
            #else
                discard; // Do not allow more additional directional lights
            #endif
            
                float diffuse = DotClamped(i.normal, lightDir);
                return _Color * diffuse * _LightColor0 * attenuation;
            }
            ENDCG
        }
    }
}
