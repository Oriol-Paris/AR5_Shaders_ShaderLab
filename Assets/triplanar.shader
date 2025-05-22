Shader "Custom/triplanar"
{
    Properties
    {
       _Tiling("Tiling", Float) = 1
        _Blend("Blend", Float) = 1

        _Color("Color", Color) = (1,1,1,1)
        _Albedo("Albedo", 2D) = "white" {}
        _Mask("Mask", 2D) = "black" {}
        _NormalMap("Normal Map", 2D) = "bump" {}

        [Toggle(_USEEMISSION_ON)] _UseEmission("Use Emission", Float) = 0
        _EmissionColor("Emission Color", Color) = (0,0,0,0)
        _Emission("Emission Map", 2D) = "black" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 300

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0
        #pragma multi_compile _ _USEEMISSION_ON

        sampler2D _Albedo;
        sampler2D _Mask;
        sampler2D _NormalMap;
        sampler2D _Emission;

        float _Tiling;
        float _Blend;
        fixed4 _Color;
        fixed4 _EmissionColor;

       struct Input
{
    float3 worldPos;
    float3 worldNormal;
    INTERNAL_DATA // <- Esto es obligatorio para usar worldNormal en Surface Shaders
};
        float4 SampleTriplanar(sampler2D tex, float3 worldPos, float3 worldNormal, float tiling)
        {
            float3 blending = pow(abs(worldNormal), _Blend);
            blending /= (blending.x + blending.y + blending.z + 1e-5);

            float2 xUV = worldPos.yz * tiling;
            float2 yUV = worldPos.xz * tiling;
            float2 zUV = worldPos.xy * tiling;

            float4 x = tex2D(tex, xUV);
            float4 y = tex2D(tex, yUV);
            float4 z = tex2D(tex, zUV);

            return x * blending.x + y * blending.y + z * blending.z;
        }

        // Triplanar Normal Sampling (unpacked)
        float3 SampleTriplanarNormal(sampler2D normalMap, float3 worldPos, float3 worldNormal, float tiling)
        {
            float3 blending = pow(abs(worldNormal), _Blend);
            blending /= (blending.x + blending.y + blending.z + 1e-5);

            float2 xUV = worldPos.yz * tiling;
            float2 yUV = worldPos.xz * tiling;
            float2 zUV = worldPos.xy * tiling;

            float3 x = UnpackNormal(tex2D(normalMap, xUV));
            float3 y = UnpackNormal(tex2D(normalMap, yUV));
            float3 z = UnpackNormal(tex2D(normalMap, zUV));

            // Tangent-space blend approximation
            return normalize(x * blending.x + y * blending.y + z * blending.z);
        }

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            float3 worldPos = IN.worldPos;
           float3 normalWS = normalize(WorldNormalVector(IN, o.Normal));

            float4 albedoSample = SampleTriplanar(_Albedo, worldPos, normalWS, _Tiling);
            float4 maskSample = SampleTriplanar(_Mask, worldPos, normalWS, _Tiling);
            float3 normalSample = SampleTriplanarNormal(_NormalMap, worldPos, normalWS, _Tiling);

            o.Albedo = albedoSample.rgb * _Color.rgb;
            o.Normal = normalSample;

            o.Metallic = maskSample.r;
            o.Smoothness = maskSample.g;
            o.Occlusion = maskSample.b;

            #if _USEEMISSION_ON
            float4 emissionSample = SampleTriplanar(_Emission, worldPos, normalWS, _Tiling);
            o.Emission = emissionSample.rgb * _EmissionColor.rgb;
            #endif
        }
        ENDCG
    }

    FallBack "Diffuse"
}