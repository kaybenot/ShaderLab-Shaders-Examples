Shader "MyShaders/GhibliGrass"
{
    Properties
    {
        _Color ("Color", Color) = (0, 0, 0, 1)
        _Shadow ("Shadow threshold", Range(0.001, 1)) = 0.7
        _ShadowColor ("Shadow color", Color) = (0, 0, 0, 1)
        _Normal ("Normal", Vector) = (0, 0, 0)
        _Position ("Position", Vector) = (0, 0, 0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "LightMode"="ForwardBase" }
        Cull Off
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #pragma multi_compile_fwdbase

            #include "UnityStandardBRDF.cginc"
            #include "AutoLight.cginc"

            uniform float4 _Color;
            uniform float _Shadow;
            uniform float4 _ShadowColor;
            uniform float3 _Normal;
            uniform float3 _Position;
            
            struct VertexData
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            
            struct Interpolators
            {
                float4 pos : SV_POSITION;
                float3 normal : TEXCOORD0;
                float4 ambient : TEXCOORD1;
                SHADOW_COORDS(2)
            };

            Interpolators vert (VertexData v)
            {
                Interpolators i;
                i.pos = UnityObjectToClipPos(v.vertex);
                i.normal = UnityObjectToWorldNormal(v.normal);
                i.ambient = float4(max(0, ShadeSH9(float4(i.normal, 1))), 1);
                TRANSFER_SHADOW(i)
                return i;
            }

            fixed4 frag (Interpolators i) : SV_Target
            {
                half shadow = SHADOW_ATTENUATION(i);
                float diffuse = DotClamped(_Normal, _WorldSpaceLightPos0.xyz);
                float4 color = shadow * diffuse < _Shadow ? _ShadowColor : _Color;
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
            uniform float _Shadow;
            uniform float4 _ShadowColor;
            uniform float3 _Normal;
            uniform float3 _Position;
            
            struct VertexData
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            
            struct Interpolators
            {
                float4 pos : SV_POSITION;
                float3 normal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                SHADOW_COORDS(2)
            };

            Interpolators vert (VertexData v)
            {
                Interpolators i;
                i.pos = UnityObjectToClipPos(v.vertex);
                i.normal = UnityObjectToWorldNormal(v.normal);
                i.worldPos = mul(unity_ObjectToWorld, v.vertex);
                TRANSFER_SHADOW(i)
                return i;
            }

            fixed4 frag (Interpolators i) : SV_Target
            {
                UNITY_LIGHT_ATTENUATION(attenuation, 0, i.worldPos);
                return DotClamped(_Normal, _WorldSpaceLightPos0.xyz) * attenuation * _LightColor0;
            }
            ENDCG
        }
        
        Tags { "LightMode"="ShadowCaster" }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #pragma multi_compile_shadowcaster

            #include "UnityStandardBRDF.cginc"
            
            uniform float3 _Position;

            float4 vert (float4 v : POSITION) : SV_POSITION
            {
                return UnityObjectToClipPos(v);
            }

            fixed4 frag (float4 pos : SV_POSITION) : SV_Target
            {
                return 0;
            }
            ENDCG
        }
    }
}
