using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class Electrocution : MonoBehaviour
{

    public GameObject cube;
    public GameObject strobe;
    public float threshold = 0.8f;
    public float offset = 1.0f;
    private GameObject[] clones;
    private int w, h;
    private bool staticMode = false;
    private int lastStrobeFrame;

    // Use this for initialization
    void Start()
    {
        Application.targetFrameRate = 10;
        lastStrobeFrame = Time.frameCount;
        clones = new GameObject[300];
        w = 15;
        h = 20;
        for (int z = 0; z < h; z++)
        {
            for (int x = 0; x < w; x++)
            {
                int index = z * w + x;
                clones[index] = Instantiate(cube, new Vector3(x, 0, z), Quaternion.identity);
                clones[index].transform.localScale = new Vector3(1.0f, 2.0f, 1.0f);
            }
        }
    } 

    // Update is called once per frame
    void Update() 
    {
        if (Input.GetKeyDown("space"))
        {
            staticMode = ! staticMode;
            Debug.Log("space down");
        }

        if (staticMode)
        {
            strobe.GetComponent<Light>().intensity = 1.0f;
            strobe.transform.localPosition = new Vector3(4.3f, 10.0f, 8.29f);
        }
        else
        {
            strobe.transform.localPosition = new Vector3(11.3f, 10.0f, 8.29f); 
            if (Time.frameCount > lastStrobeFrame + 2)
            {
                strobe.GetComponent<Light>().intensity = 1.0f - strobe.GetComponent<Light>().intensity;
                lastStrobeFrame = Time.frameCount;
            }
        }

        for (int z = 0; z < h; z++)
        {
            for (int x = 0; x < w; x++)
            {
                int index = z * w + x;
                if(staticMode)
                {
                    clones[index].transform.localScale = new Vector3(1.0f, 2.0f, 1.0f);
                    Debug.Log("space down");
                }
                else
                {
                    if (Random.Range(0.0f, 1.0f) < threshold)
                    {
                        clones[index].transform.localScale = new Vector3(1.0f, 2.0f + Random.Range(-offset, offset), 1.0f);
                    }
                    else
                    {
                        clones[index].transform.localScale = new Vector3(1.0f, 2.0f, 1.0f);
                    }
                }
            }
        }
    }
}
