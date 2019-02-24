using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class Electrocution_Center : MonoBehaviour
{

    public GameObject cube;
    public GameObject strobe1;
    public GameObject strobe2;
    public float threshold = 0.8f;
    public float offset = 1.0f;
    private GameObject[] clones;
    private int w, h;
    private bool staticMode = false;
    private int laststrobeFrame;

    // Use this for initialization
    void Start()
    {
        Application.targetFrameRate = 10;
        laststrobeFrame = Time.frameCount;
        clones = new GameObject[360];
        w = 18;
        h = 20;
        for (int z = 0; z < h; z++)
        {
            for (int x = 0; x < w; x++)
            {
                int index = z * w + x;
                clones[index] = Instantiate(cube, new Vector3(x-3, 0, z), Quaternion.identity);
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
        }

        if (staticMode)
        {
            strobe1.GetComponent<Light>().intensity = 1.0f;
            strobe1.transform.localPosition = new Vector3(4.3f, 10.0f, 8.29f);
            strobe2.GetComponent<Light>().intensity = 0.0f;
        }
        else
        {
            strobe1.transform.localPosition = new Vector3(15.0f, 10.0f, 8.29f);
            //strobe2.transform.localPosition = new Vector3(0f, 10.0f, 8.29f);
            if (Time.frameCount > laststrobeFrame + 2)
            {
                strobe1.GetComponent<Light>().intensity = 1.0f - strobe1.GetComponent<Light>().intensity;
                strobe2.GetComponent<Light>().intensity = 1.0f - strobe2.GetComponent<Light>().intensity;
                laststrobeFrame = Time.frameCount;
            }
        }

        for (int z = 0; z < h; z++)
        {
            for (int x = 0; x < w; x++)
            {
                int index = z * w + x;
                if(staticMode)
                {
                    clones[index].transform.localScale = new Vector3(1.0f, 1.0f, 1.0f);
                }
                else
                {
                    if(x > 3 && x <= 6)
                    {
                        clones[index].transform.localScale = new Vector3(1.0f, 2.0f, 1.0f);
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
}
