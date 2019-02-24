using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Glitch : MonoBehaviour
{
    public int axis; // 0: y, 1: z
    public float offset;
    public float threshold;
    private float ypos;
    private float zpos;

    // Start is called before the first frame update
    void Start()
    {
        zpos = transform.localPosition.z;
        ypos = transform.localPosition.y;
    }

    // Update is called once per frame
    void Update()
    {
        if(Random.Range(0.0f, 1.0f) < threshold)
        {
            if(axis == 0) transform.localPosition = new Vector3(transform.localPosition.x, ypos + Random.Range(-offset, offset), transform.localPosition.z);
            else transform.localPosition = new Vector3(transform.localPosition.x, transform.localPosition.y, zpos + Random.Range(-offset, offset));
        }
        else
        {
            transform.localPosition = new Vector3(transform.localPosition.x, ypos, zpos);
        }
    }
}
