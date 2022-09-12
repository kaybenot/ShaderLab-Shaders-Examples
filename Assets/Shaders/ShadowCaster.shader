Shader "MyShaders/ShadowCaster"
{
    Properties
    {
        _Color ("Color", Color) = (0, 0, 0, 1)
    }
    SubShader
    {
        Tags { "LightMode"="ShadowCaster" }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            
            float4 vert(float4 vertex : POSITION) : SV_POSITION
            {
                return UnityObjectToClipPos(vertex);
            }
            
            fixed4 frag(float4 pos : SV_POSITION) : SV_Target
            {
                return 0;
            }
            
            ENDCG
        }
    }
    FallBack "MyShaders/FullyLitColor"
}
