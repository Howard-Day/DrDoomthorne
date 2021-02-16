// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "BillboardTest"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_Main("Main", 2D) = "white" {}
		_Glow("Glow", 2D) = "white" {}
		_Frames_Dir_Speed("Frames_Dir_Speed", Vector) = (0,0,0,0)
		_GlowAmount("Glow Amount", Float) = 4
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		Offset  -1000 , -1000
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha noshadow vertex:vertexDataFunc 
		struct Input
		{
			float eyeDepth;
			float2 uv_texcoord;
		};

		uniform sampler2D _Main;
		uniform float4 _Frames_Dir_Speed;
		uniform sampler2D _Glow;
		uniform float _GlowAmount;
		uniform float _Cutoff = 0.5;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			//Calculate new billboard vertex position and normal;
			float3 upCamVec = float3( 0, 1, 0 );
			float3 forwardCamVec = -normalize ( UNITY_MATRIX_V._m20_m21_m22 );
			float3 rightCamVec = normalize( UNITY_MATRIX_V._m00_m01_m02 );
			float4x4 rotationCamMatrix = float4x4( rightCamVec, 0, upCamVec, 0, forwardCamVec, 0, 0, 0, 0, 1 );
			v.normal = normalize( mul( float4( v.normal , 0 ), rotationCamMatrix )).xyz;
			v.vertex.x *= length( unity_ObjectToWorld._m00_m10_m20 );
			v.vertex.y *= length( unity_ObjectToWorld._m01_m11_m21 );
			v.vertex.z *= length( unity_ObjectToWorld._m02_m12_m22 );
			v.vertex = mul( v.vertex, rotationCamMatrix );
			v.vertex.xyz += unity_ObjectToWorld._m03_m13_m23;
			//Need to nullify rotation inserted by generated surface shader;
			v.vertex = mul( unity_WorldToObject, v.vertex );
			v.vertex.xyz += 0;
			v.vertex.w = 1;
			o.eyeDepth = -UnityObjectToViewPos( v.vertex.xyz ).z;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float cameraDepthFade66 = (( i.eyeDepth -_ProjectionParams.y - 0.0 ) / 50.0);
			float clampResult67 = clamp( cameraDepthFade66 , 0.0 , 1.0 );
			// *** BEGIN Flipbook UV Animation vars ***
			// Total tiles of Flipbook Texture
			float fbtotaltiles5 = _Frames_Dir_Speed.x * 1.0;
			// Offsets for cols and rows of Flipbook Texture
			float fbcolsoffset5 = 1.0f / _Frames_Dir_Speed.x;
			float fbrowsoffset5 = 1.0f / 1.0;
			// Speed of animation
			float fbspeed5 = _Time.y * _Frames_Dir_Speed.z;
			// UV Tiling (col and row offset)
			float2 fbtiling5 = float2(fbcolsoffset5, fbrowsoffset5);
			// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
			// Calculate current tile linear index
			float fbcurrenttileindex5 = round( fmod( fbspeed5 + 0.0, fbtotaltiles5) );
			fbcurrenttileindex5 += ( fbcurrenttileindex5 < 0) ? fbtotaltiles5 : 0;
			// Obtain Offset X coordinate from current tile linear index
			float fblinearindextox5 = round ( fmod ( fbcurrenttileindex5, _Frames_Dir_Speed.x ) );
			// Multiply Offset X by coloffset
			float fboffsetx5 = fblinearindextox5 * fbcolsoffset5;
			// Obtain Offset Y coordinate from current tile linear index
			float fblinearindextoy5 = round( fmod( ( fbcurrenttileindex5 - fblinearindextox5 ) / _Frames_Dir_Speed.x, 1.0 ) );
			// Reverse Y to get tiles from Top to Bottom
			fblinearindextoy5 = (int)(1.0-1) - fblinearindextoy5;
			// Multiply Offset Y by rowoffset
			float fboffsety5 = fblinearindextoy5 * fbrowsoffset5;
			// UV Offset
			float2 fboffset5 = float2(fboffsetx5, fboffsety5);
			// Flipbook UV
			half2 fbuv5 = i.uv_texcoord * fbtiling5 + fboffset5;
			// *** END Flipbook UV Animation vars ***
			float2 break10 = fbuv5;
			float4 appendResult36 = (float4(_WorldSpaceCameraPos.x , _WorldSpaceCameraPos.y , _WorldSpaceCameraPos.z , 0.0));
			float4 transform37 = mul(unity_ObjectToWorld,float4( 0,0,0,1 ));
			float4 appendResult38 = (float4(transform37.x , transform37.y , transform37.z , 0.0));
			float4 normalizeResult46 = normalize( ( appendResult36 - appendResult38 ) );
			float4 break42 = normalizeResult46;
			float4 appendResult13 = (float4(break10.x , ( ( ( break10.y / 8.0 ) - ( floor( ( ( degrees( atan2( break42.z , break42.x ) ) + -22.5 ) / 45.0 ) ) / 8.0 ) ) + ( floor( ( ( degrees( atan2( float4( unity_ObjectToWorld[0][0],unity_ObjectToWorld[1][0],unity_ObjectToWorld[2][0],unity_ObjectToWorld[3][0] ).z , float4( unity_ObjectToWorld[0][0],unity_ObjectToWorld[1][0],unity_ObjectToWorld[2][0],unity_ObjectToWorld[3][0] ).x ) ) + 22.5 ) / 45.0 ) ) / 8.0 ) ) , 0.0 , 0.0));
			float4 tex2DNode3 = tex2D( _Main, appendResult13.xy );
			o.Emission = ( ( ( 1.0 - clampResult67 ) * tex2DNode3 ) + ( tex2D( _Glow, appendResult13.xy ) * _GlowAmount ) ).rgb;
			o.Alpha = 1;
			clip( tex2DNode3.a - _Cutoff );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18800
1;1256;1941;843;1091.223;769.4152;1.060194;True;False
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;37;-2854.624,-91.52203;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldSpaceCameraPos;35;-2892.298,-328.0237;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;36;-2569.986,-338.4885;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;38;-2584.636,-111.4049;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;39;-2407.783,-256.864;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.NormalizeNode;46;-2267.556,-262.0961;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.BreakToComponentsNode;42;-2095.936,-289.304;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.ObjectToWorldMatrixNode;53;-2160.767,-33.50322;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.VectorFromMatrixNode;54;-1944.537,-75.21258;Inherit;False;Column;0;1;0;FLOAT4x4;1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ATan2OpNode;41;-1944.195,-296.6298;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ATan2OpNode;55;-1707.299,-106.1317;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DegreesOpNode;45;-1813.389,-288.2579;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;6;-1952.719,-694.3495;Inherit;False;Property;_Frames_Dir_Speed;Frames_Dir_Speed;3;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;7;-1875.501,-490.3496;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;4;-1987.662,-838.3861;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DegreesOpNode;56;-1576.493,-97.75981;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;65;-1585.555,-295.4604;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-22.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;47;-1373.583,-313.9083;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;45;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCFlipBookUVAnimation;5;-1652.728,-846.1536;Inherit;False;0;0;6;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;71;-1426.555,-104.4604;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;22.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;49;-1267.124,-318.2558;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;57;-1278.687,-97.41019;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;45;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;10;-1425.713,-846.5491;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.FloorOpNode;58;-1134.228,-127.7577;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;11;-1278.731,-614.2938;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;8;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;50;-1111.199,-355.9288;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;8;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;51;-916.5563,-387.3228;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;59;-977.3031,-165.4308;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;8;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;61;-782.1603,-385.8368;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CameraDepthFade;66;-704.5549,-730.4604;Inherit;False;3;2;FLOAT3;0,0,0;False;0;FLOAT;50;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;67;-203.5549,-728.4604;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;13;-556.5078,-462.0247;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;3;-417.5,-490.4982;Inherit;True;Property;_Main;Main;1;0;Create;True;0;0;0;False;0;False;-1;cd21cfcc76a382a49ab0c96009704ad5;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;75;-101.0017,-187.3686;Inherit;False;Property;_GlowAmount;Glow Amount;4;0;Create;True;0;0;0;False;0;False;4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;70;-41.55493,-684.4604;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;72;-415.8794,-299.7491;Inherit;True;Property;_Glow;Glow;2;0;Create;True;0;0;0;False;0;False;-1;0399cf18addab6f4a86a8dbcedb0d706;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;27.28185,-335.7957;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;65.44507,-549.4604;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BillboardNode;1;-238.471,26.76612;Inherit;False;Cylindrical;True;0;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;73;267.9459,-479.9822;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;9;429.765,-470.0369;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;BillboardTest;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;True;-1000;False;-1;-1000;False;-1;False;0;Custom;0.5;True;False;0;False;TransparentCutout;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;36;0;35;1
WireConnection;36;1;35;2
WireConnection;36;2;35;3
WireConnection;38;0;37;1
WireConnection;38;1;37;2
WireConnection;38;2;37;3
WireConnection;39;0;36;0
WireConnection;39;1;38;0
WireConnection;46;0;39;0
WireConnection;42;0;46;0
WireConnection;54;0;53;0
WireConnection;41;0;42;2
WireConnection;41;1;42;0
WireConnection;55;0;54;3
WireConnection;55;1;54;1
WireConnection;45;0;41;0
WireConnection;56;0;55;0
WireConnection;65;0;45;0
WireConnection;47;0;65;0
WireConnection;5;0;4;0
WireConnection;5;1;6;1
WireConnection;5;3;6;3
WireConnection;5;5;7;0
WireConnection;71;0;56;0
WireConnection;49;0;47;0
WireConnection;57;0;71;0
WireConnection;10;0;5;0
WireConnection;58;0;57;0
WireConnection;11;0;10;1
WireConnection;50;0;49;0
WireConnection;51;0;11;0
WireConnection;51;1;50;0
WireConnection;59;0;58;0
WireConnection;61;0;51;0
WireConnection;61;1;59;0
WireConnection;67;0;66;0
WireConnection;13;0;10;0
WireConnection;13;1;61;0
WireConnection;3;1;13;0
WireConnection;70;0;67;0
WireConnection;72;1;13;0
WireConnection;74;0;72;0
WireConnection;74;1;75;0
WireConnection;68;0;70;0
WireConnection;68;1;3;0
WireConnection;73;0;68;0
WireConnection;73;1;74;0
WireConnection;9;2;73;0
WireConnection;9;10;3;4
WireConnection;9;11;1;0
ASEEND*/
//CHKSM=30452862E9E7B1E982BC057865C0782096668D80