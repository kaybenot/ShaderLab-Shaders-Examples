Shader "MyShaders/CutoutShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Cutout ("Cutout threshold", Range(0, 1)) = 0.9
    }
    SubShader
    {
        Tags { "RenderType"="TransparentCutout" "Queue"="AlphaTest" }
        Cull Off
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct VertexData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 position : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            uniform sampler2D _MainTex;
            uniform float4 _MainTex_ST;
            uniform float _Cutout;

            Interpolators vert (VertexData v)
            {
                Interpolators o;
                o.position = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (Interpolators i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                if(col.a < _Cutout)
                    discard;
                return col;
            }
            ENDCG
        }
    }
}
