using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Tunnel_Floor_MovePlane : MonoBehaviour
{
    public float yDecrement;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        this.transform.Translate(new Vector3(0.0f, -yDecrement));
    }
}
