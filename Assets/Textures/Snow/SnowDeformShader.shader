Shader "Custom/SnowDeformShader"
{
    Properties
    {
        _SnowTex("Snow Texture", 2D) = "white" {}
        _RoughSnowTex("Rough Snow Texture", 2D) = "white" {}
        _DirtTex("Dirt Texture", 2D) = "white" {}
        _HeightMap("Height Map", 2D) = "black" {}
        _HeightScale("Height Scale", Float) = 0.1
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
#include "UnityCG.cginc"

sampler2D _SnowTex;
sampler2D _RoughSnowTex;
sampler2D _DirtTex;
sampler2D _HeightMap;
float _HeightScale;

struct appdata
{
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
};

struct v2f
{
    float4 pos : SV_POSITION;
    float2 uv : TEXCOORD0;
    float3 worldNormal : TEXCOORD1;
    float3 worldPos : TEXCOORD2;
};

//float3 RecalculateNormal(float2 uv)
//{
//    float2 texelSize = float2(1.0 / 1024.0, 1.0 / 1024.0);
//    float hL = tex2Dlod(_HeightMap, float4(uv - float2(texelSize.x, 0), 0, 0)).r;
//    float hR = tex2Dlod(_HeightMap, float4(uv + float2(texelSize.x, 0), 0, 0)).r;
//    float hD = tex2Dlod(_HeightMap, float4(uv - float2(0, texelSize.y), 0, 0)).r;
//    float hU = tex2Dlod(_HeightMap, float4(uv + float2(0, texelSize.y), 0, 0)).r;

//    float3 dx = float3(1, 0, -(hR - hL) * _HeightScale);
//    float3 dy = float3(0, 1, -(hU - hD) * _HeightScale);

//    return normalize(cross(dy, dx));
//}

v2f vert(appdata v)
{
    v2f o;

    float height = tex2Dlod(_HeightMap, float4(v.uv, 0, 0)).r;
    float3 offset = float3(0, -height * _HeightScale, 0); // negativo = hacia abajo

    float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz + offset;
    o.pos = UnityObjectToClipPos(v.vertex + float4(offset, 0));
    o.uv = v.uv;
    o.worldPos = worldPos;
   // o.worldNormal = RecalculateNormal(v.uv);

    return o;
}

fixed4 frag(v2f i) : SV_Target
{
    float height = tex2D(_HeightMap, i.uv).r;

    float3 texColor;

    if (height > 0.7)
        texColor = tex2D(_DirtTex, i.uv).rgb;
    else if (height > 0.3)
        texColor = tex2D(_RoughSnowTex, i.uv).rgb;
    else
        texColor = tex2D(_SnowTex, i.uv).rgb;
    
    
    return float4(texColor, 1);
}
            ENDCG
        }
    }
}