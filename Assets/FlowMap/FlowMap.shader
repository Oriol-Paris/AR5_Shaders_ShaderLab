Shader "Custom/RealisticWaterFlow"
{
    Properties
    {
        _Normals ("Normal Map", 2D) = "bump" {}
        _NormalStrength ("Normal Strength", Range(0,2)) = 1 
        _FlowMap ("Flow Map", 2D) = "white" {}
        _Tiling ("Normal Map Tiling", Float) = 0.1 
        _FlowmapStrength ("Flowmap Strength", Float) = 0.5 
        _Speed ("Speed", Float) = 0.5 
        _DepthRange ("Depth Range", Float) = 10 
        _DepthColor ("Depth Color", Color) = (0, 0.3, 0.6, 1)
        _DistortionStrength ("Distortion Strength", Float) = 1 
    }

    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        LOD 200
        Blend SrcAlpha OneMinusSrcAlpha 
        ZWrite Off 
        Cull Back 

        CGPROGRAM
        #pragma surface surf Standard alpha:fade

        sampler2D _Normals;
        sampler2D _FlowMap;

        float _NormalStrength; 
        float _Tiling;
        float _FlowmapStrength;
        float _Speed;
        float _DepthRange;
        float4 _DepthColor;
        float _DistortionStrength;

        struct Input
        {
            float2 uv_Normals; 
            float3 worldPos; 
            float3 worldRefl; 
            float3 viewDir; 
            INTERNAL_DATA 
        };

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float time = _Time.y * _Speed;

            float2 baseNormalUV = IN.uv_Normals * _Tiling; 
            float2 flowMapUV = IN.uv_Normals; 
            
            float2 flow = tex2D(_FlowMap, flowMapUV).rg * 2 - 1;
            flow *= _FlowmapStrength; 

            float2 uv1 = baseNormalUV + flow * time;
            float2 uv2 = baseNormalUV - flow * time;

            float3 normal1 = UnpackNormal(tex2D(_Normals, uv1));
            float3 normal2 = UnpackNormal(tex2D(_Normals, uv2));
            float3 finalNormal = normalize(normal1 + normal2);

            finalNormal = lerp(float3(0,0,1), finalNormal, _NormalStrength);
            o.Normal = finalNormal; 

            float depth = saturate(1 - (IN.worldPos.y / _DepthRange));
            depth = pow(depth, 0.4);

            float3 waterColor = _DepthColor.rgb * depth * 2.5;
            o.Albedo = saturate(waterColor); 

            o.Alpha = saturate(depth + 0.1); 

            o.Smoothness = 0.95; 
            o.Metallic = 0.5;   
        }
        ENDCG
    }

    FallBack "Transparent/Diffuse" 
}