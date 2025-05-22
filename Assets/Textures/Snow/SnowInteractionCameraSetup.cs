using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class NewBehaviourScript : MonoBehaviour
{
  
    public Transform target; // La esfera
    public Shader drawShader;
    private Material drawMat;
    private RenderTexture snowRT;
    public Camera cam;

    public float groundHeight = 0.0f;
    public float drawRadius = 0.05f;
    public float maxDepth = 0.3f; // Máximo hundimiento que se puede representar

    private void OnEnable()
    {
        SetupCamera();
        SetupRenderTexture();
        SetupMaterial();
    }

    void Update()
    {
#if UNITY_EDITOR
        if (!Application.isPlaying)
        {
            SceneView.RepaintAll(); // Permite que se actualice en Editor
        }
#endif

        if (target && drawMat && cam && snowRT)
        {
            Vector3 localPos = transform.InverseTransformPoint(target.position);
            Vector2 uvPos = new Vector2(localPos.x + 0.5f, (localPos.z + 0.5f));
            
            

            // Cálculo de profundidad basada en posición Y
            float contactY = target.position.y;
            float depth = Mathf.Clamp01((target.position.y - groundHeight) / maxDepth);
            drawMat.SetFloat("_Strength", depth);

            drawMat.SetVector("_DrawPosition", new Vector4(uvPos.x, uvPos.y, 0, 0));
            drawMat.SetFloat("_Radius", drawRadius);
           

            Graphics.Blit(null, snowRT, drawMat);
        }
    }

    void SetupCamera()
    {
        cam = GetComponent<Camera>();
        if (!cam)
        {
            cam = gameObject.AddComponent<Camera>();
        }

        cam.orthographic = true;
        cam.orthographicSize = 0.5f;
        cam.clearFlags = CameraClearFlags.SolidColor;
        cam.backgroundColor = Color.black;
        cam.enabled = false; // no la necesitamos activa
    }

    void SetupRenderTexture()
    {
        if (!snowRT || !snowRT.IsCreated())
        {
            snowRT = new RenderTexture(1024, 1024, 0, RenderTextureFormat.RFloat);
            snowRT.wrapMode = TextureWrapMode.Clamp;
            snowRT.Create();
        }

        Shader.SetGlobalTexture("_HeightMap", snowRT);
    }

    void SetupMaterial()
    {
        if (!drawShader) return;

        if (!drawMat)
        {
            drawMat = new Material(drawShader);
        }
    }
}