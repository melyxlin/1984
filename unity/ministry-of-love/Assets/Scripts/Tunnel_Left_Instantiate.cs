using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Tunnel_Left_Instantiate : MonoBehaviour
{
    public GameObject cube;
    public GameObject camera;
    public bool dir; // 1: left, 0: right
    public float elapsedTime;
    public float timeScale = 0.1f;
    public float camDist = 3.0f;
    public float noiseOffset = 0.05f;
    private GameObject[] clones;
    private int w, h;
    public bool endMode;


    void Start()
    {
        clones = new GameObject[600];
        w = 60;
        h = 10;
        Vector3 cubeScale = cube.transform.localScale;
        float startX = dir ? -2.5f : 2.5f;
        for(int y = 0; y < h; y++) {
            for (int z = 0; z < w; z++) {
                int index = y * w + z;
                clones[index] = Instantiate(cube, new Vector3(startX, y*cubeScale.y+ 0.25f, z*cubeScale.z + cube.transform.localPosition.z), Quaternion.identity);
                clones[index].transform.localScale = new Vector3(0.0f, cubeScale.y, cubeScale.z);
                clones[index].GetComponent<Renderer>().enabled = false;
            }
        }

        cube.GetComponent<Renderer>().enabled = false;
        endMode = false;
    }

    void Update()
    {
        if(Input.GetKeyDown("space"))
        {
            endMode = true;
        }

        float camDepth = camera.transform.localPosition.z;
        elapsedTime = Time.time * timeScale;
        for (int y = 0; y < h; y++)
        {
            for (int z = 0; z < w; z++)
            {
                int index = y * w + z;
                if(clones[index].transform.localPosition.z - camDist < camDepth)
                {
                    Vector3 scale = clones[index].transform.localScale;
                    if ( (!endMode && (scale.x < Mathf.PerlinNoise(y * noiseOffset, z * noiseOffset) * 5.0f)) )
                    {
                        clones[index].transform.localScale = new Vector3(scale.x + 0.01f, scale.y, scale.z);
                    } else if (endMode && scale.x < 5.0f) {
                        clones[index].transform.localScale = new Vector3(scale.x + 0.02f, scale.y, scale.z);
                    }
                    if(scale.x > 0) clones[index].GetComponent<Renderer>().enabled = true;
                }
            }
        }
    }
}
