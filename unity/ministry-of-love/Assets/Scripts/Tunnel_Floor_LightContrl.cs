using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Tunnel_Floor_LightContrl : MonoBehaviour
{

    public float decrement;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (this.GetComponent<Light>().range > 50.0f) this.GetComponent<Light>().range -= decrement;
    }
}
