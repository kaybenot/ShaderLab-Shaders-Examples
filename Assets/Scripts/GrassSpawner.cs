using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class GrassSpawner : MonoBehaviour
{
    public GameObject GrassObj;
    public float Step = 0.1f;
    
    private Terrain terrain;
    private static readonly int Normal = Shader.PropertyToID("_Normal");
    private static readonly int Position = Shader.PropertyToID("_Position");

    private void Start()
    {
        terrain = GetComponent<Terrain>();

        Vector3 pos = terrain.transform.position;
        for (float x = pos.x + Step; x < terrain.terrainData.bounds.max.x + pos.x; x += Step)
        {
            for (float z = pos.z + Step; z < terrain.terrainData.bounds.max.z + pos.z; z += Step)
            {
                Vector3 location = new Vector3(x, 0, z);
                location.y = terrain.SampleHeight(location);
                GameObject grass = Instantiate(GrassObj, location, Quaternion.Euler(-90f, 0f, Random.Range(0f, 360f)));
                grass.transform.parent = transform;
                Vector3 normal = terrain.terrainData.GetInterpolatedNormal(x, z);
                MeshRenderer mr = grass.GetComponent<MeshRenderer>();
                mr.sharedMaterial.SetVector(Normal, normal);
                mr.sharedMaterial.SetVector(Position, normal);
            }
        }
    }
}
