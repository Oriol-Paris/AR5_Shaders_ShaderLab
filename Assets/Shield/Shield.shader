Shader "Custom/ShieldEffectFinalGlowOnly"
{
    Properties
    {
        _MainTex("Hex Pattern", 2D) = "white" {}
        _Color("Glow Tint", Color) = (0, 1, 1, 1)
        _Texture_Speed("Texture Scroll Speed", Float) = 1
        _Texture_Tiling("Texture Tiling", Vector) = (16, 20, 0, 0)
        _Scanline_Speed("Scanline Speed", Float) = -0.1
        _Scanline_Density("Scanline Density", Float) = 50
        _Fresnel_Power("Fresnel Power", Float) = 5
    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 200
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _Texture_Speed;
            float4 _Texture_Tiling;
            float _Scanline_Speed;
            float _Scanline_Density;
            float _Fresnel_Power;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
                float4 screenPos : TEXCOORD3;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.screenPos = ComputeScreenPos(o.pos);
                return o;
            }

            float softLight(float base, float blend)
            {
                return (blend < 0.5) ? (2.0 * base * blend + base * base * (1.0 - 2.0 * blend)) :
                                       (sqrt(base) * (2.0 * blend - 1.0) + 2.0 * base * (1.0 - blend));
            }

            float4 frag(v2f i) : SV_Target
            {
                float time = _Time.y;

                // Scrolling texture UV
                float2 scrollUV = i.uv + float2(0, time * _Texture_Speed);
                float4 tex = tex2D(_MainTex, scrollUV * _Texture_Tiling.xy);
                float hexMask = tex.r;

                // Fresnel
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                float fresnel = pow(1.0 - dot(viewDir, normalize(i.worldNormal)), _Fresnel_Power);

                // Scanlines
                float scan = abs(sin(i.screenPos.y * _Scanline_Density + time * _Scanline_Speed));

                // Alpha exacta como en Shader Graph
                float alpha = softLight(fresnel, scan * hexMask);

                // Color final: solo el color de textura + fresnel + glow tint
                float3 color = tex.rgb * _Color.rgb;

                return float4(color, alpha);
            }
            ENDHLSL
        }
    }
}
