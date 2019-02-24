using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Tunnel_Camera : MonoBehaviour
{
    public float zIncrement;

    void Start()
    {
        
    }

    void Update()
    {
        this.transform.localPosition = new Vector3(this.transform.localPosition.x, this.transform.localPosition.y, this.transform.localPosition.z + zIncrement);
    }
}
