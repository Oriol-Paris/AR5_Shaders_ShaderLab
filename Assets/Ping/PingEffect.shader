Shader "Custom/PingWorldEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Ping Color", Color) = (1,1,0,1)
        _Strength ("Strength", Range(0,5)) = 1
        _Width ("Width", Range(0.01,1)) = 0.1
        _Speed ("Speed", Float) = 1
        _MaxDistance ("Max Distance", Float) = 30
        _Frequency ("Frequency", Float) = 0.25
        _Distance ("Current Distance", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            ZTest Always Cull Off ZWrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;
            float4 _Color;
            float _Strength;
            float _Width;
            float _Distance;
            float4x4 _CameraInverseProjection;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float3 ReconstructWorldPos(float2 uv)
            {
                float rawDepth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv);
                float4 clip = float4(uv * 2 - 1, rawDepth * 2 - 1, 1);
                float4 view = mul(_CameraInverseProjection, clip);
                view /= view.w;
                float4 world = mul(unity_CameraToWorld, view);
                return world.xyz;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 worldPos = ReconstructWorldPos(i.uv);
                float3 camPos = unity_CameraToWorld._m03_m13_m23;
                float dist = distance(worldPos, camPos);

                float edge = smoothstep(_Distance - _Width, _Distance, dist) *
                             (1.0 - smoothstep(_Distance, _Distance + _Width, dist));

                float4 col = tex2D(_MainTex, i.uv);
                col.rgb += _Color.rgb * edge * _Strength;
                return col;
            }
            ENDCG
        }
    }
}
