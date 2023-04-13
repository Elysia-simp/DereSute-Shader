Shader "Cygames/3DLive/Chara/CharaDefaultRich"
{
	Properties
	{	//anything commented out is something i simply do not understand
		[Header(Custom)]
		[Enum(Static, 0, Dynamic, 1, None, 2)] _OutlineType ("Outline Scale type", Float) = 0
		[Space(10)]
		[Header(Original Shader Stuff)]


//		[MaterialToggle] _UseFaceTex ("UseFaceTex", Float) = 0
//		[KeywordEnum(Original, Accessory, Head, Object, Body)] _TexturePack ("TexturePack", Float) = 0
		[Space(5)] _MainTex ("Diffuse Texture", 2D) = "white" { }
		_ControlMap ("_ControlMap", 2D) = "white" { }
		_RimNormalAdjust ("_RimNormalAdjust", Range(-2, 2)) = 0
		_RimPower ("_RimPower", Range(1, 16)) = 4
		_RimRate ("_RimRate", Range(0, 2)) = 0.5
		_RimColor ("_RimColor", Color) = (1,1,1,1)
//		_RimShadow ("_RimShadow", Range(0, 2)) = 0
		_SpecTex ("_SpecTex", 2D) = "white" { }
		[Toggle(DISABLE_SPECULAR)] _bSpecular ("Disable Specular", Float) = 0
		_SpecPower ("_SpecPower", Range(1, 200)) = 32
		_SpecRate ("_SpecRate", Range(0, 1)) = 0.2
		_SpecColor ("_SpecColor", Color) = (1,1,1,1)
		_EnvRate ("_EnvRate", Range(0, 1)) = 0.5
		_EnvBias ("_EnvBias", Range(0, 8)) = 1
		_OutlineTex ("Outline Texture", 2D) = "red" { }
		_outlineParam ("Outline Param : x=Width y=Brightness", Vector) = (1,0.5,0,0)
		_outlineZOffset ("Outline Z Offset", Float) = 0.0015
		_RimColorMulti ("_RimColorMulti", Color) = (1,1,1,1)
//		_HeightLightParam ("_HeightLightParam", Vector) = (0,1,0,0)
//		_HeightLightColor ("_HeightLightColor", Color) = (0,0,0,0)
		_StencilValue ("_StencilValue", Float) = 127
	}
	SubShader
	{
		Tags { "Chara" = "MyShadow" "Mirror" = "Chara" "QUEUE" = "Geometry-1" "RenderType" = "Opaque" "LightMode" = "Vertex" }
		Blend One Zero, Zero One
		ZWrite On
		Cull Back
		Stencil {
		ref [_StencilValue]
		Comp Always
		Pass Replace
		Fail Keep
		ZFail Keep
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
			float4 color : COLOR;
			float2 uv : TEXCOORD0;
			float4 tangent : TANGENT;
		};
		struct v2f
		{
			float2 uv : TEXCOORD0;
			UNITY_FOG_COORDS(1)
			float4 color : COLOR;
			half3 normal : NORMAL;
			float4 tangent : TANGENT;
			float4 vertex : SV_POSITION;
			float4 posWorld : TEXCOORD1;
		};
		sampler2D _MainTex;
		sampler2D _ControlMap;
		sampler2D _SpecTex;
		float4 _MainTex_ST;
		float4 _RimColor;
		float4 _RimColorMulti;
		float4 _ControlMap_ST;
		float4 _SpecTex_ST;
		float _SpecPower;
		float _SpecRate;
		float4 _SpecColor;
		float _bSpecular;
		float _RimPower;
		float _RimRate;
		float _EnvRate;
		float _EnvBias;
		float _RimNormalAdjust;


		v2f vert (appdata v)
		{
			v2f o;
			o.vertex = UnityObjectToClipPos(v.vertex);
			o.uv = TRANSFORM_TEX(v.uv, _MainTex);
			o.normal = normalize( mul ( float4(v.tangent.xyz, 1.0), unity_WorldToObject).xyz);
			UNITY_TRANSFER_FOG(o,o.vertex);
			o.posWorld = mul(unity_ObjectToWorld, v.vertex);
			o.color = v.color;
			return o;
		}

		fixed4 frag (v2f i) : SV_Target
		{
			// sample the texture
			fixed4 col = tex2D(_MainTex, i.uv);
			//multi
			fixed4 multi = tex2D(_ControlMap, i.uv);
			multi.b *= _RimColorMulti;
			// apply fog
			UNITY_APPLY_FOG(i.fogCoord, col);
			//spec
			float3 normalDir = i.normal += _RimNormalAdjust;
			float3 viewDir = normalize( _WorldSpaceCameraPos.xyz - i.posWorld.xyz);
			float ndoth = saturate(pow(dot(normalDir, normalize(viewDir)), _SpecPower)) * _SpecRate;

			fixed4 spec = tex2D(_SpecTex, i.uv) * ndoth * _SpecColor;
			if(_bSpecular == 1)
			{
			 spec *= 0;	
			}
			else
			{
			 spec *= 1;
			}
			//rimlighting
			float rimUV = saturate(pow(1.0 - dot(viewDir, normalDir), _RimPower) * _RimRate);

			//env
			float ENV = saturate(pow(dot(normalDir, viewDir), _EnvBias) * _EnvRate) ;



			//lerp stuff
			col.rgb = lerp(col.rgb, col.rgb + rimUV, saturate(multi.b * _RimColor));
			col.rgb = lerp(col.rgb, col.rgb + spec, multi.r);
			col.rgb = lerp(col.rgb, col.rgb + ENV, multi.g);
			col.rgb *= unity_LightColor[0].rgb;
			col = saturate(col);
			return col;
		}
		ENDCG
		}
 
		Pass
		{
			Tags { "Chara" = "MyShadow" "Mirror" = "Chara" "QUEUE" = "Geometry-1" "RenderType" = "Opaque" "LightMode" = "Vertex" }
			Stencil {
			ref [_StencilValue]
			Comp Always
			Pass Replace
			Fail Keep
			ZFail Keep
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
				float4 color : COLOR;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
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
			float _OutlineType;

			v2f vert (appdata v)
			{
				v2f o = (v2f)0;
				o.uv = v.uv;
				o.color = v.color;
				//once again adjusted for asset ripper models and models scaled by 100
				if(_OutlineType == 1){
				v.vertex.xyz += v.normal.xyz * _outlineZOffset * (v.color *  _outlineParam.x) * (length(ObjSpaceViewDir(v.vertex)) * 1.7) ;
				}
				if(_OutlineType == 0){
					v.vertex.xyz += v.normal.xyz * _outlineZOffset * (v.color *  _outlineParam.x);
				}
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
