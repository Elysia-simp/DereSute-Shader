//I have no idea why they call it this i'm just reading what they wrote LOL
Shader "Cygames/3DLive/Chara/Transparent2Tex" {
	Properties {
		_MainTex ("Diffuse Texture", 2D) = "white" {}
		_MainTexAlpha ("Diffuse Alpha Texture", 2D) = "white" {}
		_CharaColor ("Color", Vector) = (1,1,1,1)
		[HideInInspector] _StencilValue ("_StencilValue", Float) = 127
	}
    SubShader
    {
        Tags { "Mirror" = "Chara" "QUEUE" = "Geometry-1" "RenderType" = "Opaque" "LightMode" = "Vertex" }
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _MainTexAlpha;
            float4 _MainTexAlpha_ST;
            float4 _CharaColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv) * _CharaColor;
                col.a = tex2D(_MainTexAlpha, i.uv);

                col.rgb *= unity_LightColor[0];


                return col;
            }
            ENDCG
        }
    }
}
