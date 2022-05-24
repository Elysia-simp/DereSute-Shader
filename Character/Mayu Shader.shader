Shader "Cygames/3DLive/Chara/CharaMayuRich"
{
    Properties
    {   //anything commented out is something i simply do not understand
        _MainTex ("Diffuse Texture", 2D) = "white" { }
        _OutlineTex ("Outline Texture", 2D) = "red" { }
        _outlineParam ("Outline Param : x=Width y=Brightness", Vector) = (1,0.5,0,0)
//        _HeightLightParam ("_HeightLightParam", Vector) = (0,1,0,0)
//        _HeightLightColor ("_HeightLightColor", Color) = (0,0,0,0)
    }
    SubShader
    {
        Tags { "Mirror" = "Chara" "QUEUE" = "Geometry-1" "RenderType" = "Opaque" "LightMode" = "Vertex" }
        Blend One Zero, Zero One
        ZTest Off
        ZWrite On
        Stencil {
        Ref 1
        Comp notequal
        Pass keep
    }
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
                half3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                half3 normal : NORMAL;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

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
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                //specular
                col.rgb *= unity_LightColor[0].rgb;
                            
                return col;
            }
            ENDCG
        }
        Pass
		{
			Tags { "Chara" = "MyShadow" "Mirror" = "Chara" "QUEUE" = "Geometry-1" "RenderType" = "Opaque" "LightMode" = "Vertex" }
			Stencil {
            Ref 1
            Comp notequal
            Pass keep
            }
			Cull Front
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
			
			struct appdata
			{
				float4 vertex : POSITION;
				half3 normal : NORMAL;
				float4 color : COLOR;
				float2 uv : TEXCOORD0;
				float4 tangent : TANGENT;
            };

			struct v2f
			{
				float4 position : SV_POSITION;
				float4 color : COLOR;
				float2 uv : TEXCOORD0;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _outlineZOffset;
			float2 _outlineParam;

			v2f vert (appdata v)
			{
				v2f o = (v2f)0;
				o.uv = v.uv;
				o.color = v.color;
				//once again adjusted for asset ripper models and models scaled by 100
				v.vertex.xyz += v.tangent.xyz * _outlineZOffset * (v.color.r * v.color.g * v.color.b *  _outlineParam.x) * (length(ObjSpaceViewDir(v.vertex)) * 1.5) ;
				o.position = UnityObjectToClipPos(v.vertex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				col.rgb *= _outlineParam.y;
				col.rgb *= unity_LightColor[0].rgb;

				return col;
			}
			ENDCG
		}
    }
}
