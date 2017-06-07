// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/LenseEffect"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
		_Amount("Amount", Range(0, 100)) = 1.0
		_Size("Size", Range(0, 2)) = 1.0
		_InnerRing("Inner Ring", Range(0, 2)) = 1.0
		_OuterLimit("Outer Limit", Range(0, 2)) = 1.0
		_Position("Position", Range(0, 1)) = 1.0
	}
	SubShader
	{
		// No culling or depth
		Cull Off 
		ZTest Always

		Tags{ 
			"Queue" = "Transparent+1" 
			"DisableBatching" = "True" 
		}


		GrabPass{
			//"_ScreenTex"
		}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float4 grabPos : TEXCOORD1; 
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 grabPos : TEXCOORD1;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.grabPos = ComputeGrabScreenPos(o.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			sampler2D _GrabTexture;
			fixed4 _Color; 
			half _Amount; 
			half _Size; 
			half _InnerRing;
			half _OuterLimit; 
			half _Position; 

			float normalizeRange(float minimum, float maximum, float value) {
				float normalized = (value - minimum) / (maximum - minimum);
				normalized = min(1, normalized);
				normalized = max(0, normalized);
				return normalized;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				float time = _Position * 0.5; //(sin(_Time.y) + 1) * 0.5;//_Position; 
				float4 grabUv = i.grabPos; 

				float distFromCenter = 1 - normalizeRange(time, _Size + time, length(i.uv - 0.5));
				float subtractFromCenter = 1 - normalizeRange(time, _InnerRing + time, length(i.uv - 0.5));
				float distanceFromOutside = normalizeRange(_OuterLimit, 0, length(i.uv - 0.5));

				distFromCenter -= subtractFromCenter; 
				distFromCenter *= distanceFromOutside;

				float2 directionFromCenter = normalize(0.5 - i.uv);
				distFromCenter = min(1, distFromCenter);
				distFromCenter = max(0, distFromCenter);

				float timeMult = normalizeRange(0, 1, time) * 2;
				grabUv.xy += distFromCenter * _Amount * directionFromCenter * timeMult;
				half4 bgcolor = tex2Dproj(_GrabTexture, grabUv);

				fixed4 rainbow = tex2D(_MainTex, directionFromCenter * bgcolor.xy);
				fixed4 finalCol = bgcolor + rainbow * _Color * distFromCenter * timeMult;
				return finalCol;
			}
			ENDCG
		}
	}
}
