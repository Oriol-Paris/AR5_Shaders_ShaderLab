using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class PingPostProcess : MonoBehaviour
{
    public Material pingMaterial;

    float currentDistance = 0f;
    float lastPingTime = 0f;
    Camera cam;

    void Start()
    {
        cam = GetComponent<Camera>();
        cam.depthTextureMode |= DepthTextureMode.Depth;
    }

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (!pingMaterial)
        {
            Graphics.Blit(src, dest);
            return;
        }

        float freq = pingMaterial.GetFloat("_Frequency");
        float speed = pingMaterial.GetFloat("_Speed");
        float maxDist = pingMaterial.GetFloat("_MaxDistance");

        if (Time.time - lastPingTime > freq)
        {
            lastPingTime = Time.time;
            currentDistance = 0;
        }

        currentDistance += Time.deltaTime * speed;
        currentDistance = Mathf.Min(currentDistance, maxDist);
        pingMaterial.SetFloat("_Distance", currentDistance);

        pingMaterial.SetMatrix("_CameraInverseProjection", cam.projectionMatrix.inverse);

        Graphics.Blit(src, dest, pingMaterial);
    }
}
