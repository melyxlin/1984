using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Tunnel_Camera : MonoBehaviour
{
    public float zIncrement;
    public float elapsedTime;
    public float xDegScale;
    public float yIncrement;

    void Start()
    {
        
    }

    void Update()
    {
        this.transform.localPosition = new Vector3(this.transform.localPosition.x, this.transform.localPosition.y, this.transform.localPosition.z + zIncrement);
        //if(this.transform.localPosition.y <= 2.50f) this.transform.localPosition = new Vector3(this.transform.localPosition.x, this.transform.localPosition.y + yIncrement, this.transform.localPosition.z);
        //if(this.transform.localRotation.x >= 0) this.transform.Rotate(Vector3.left * Time.time * xDegScale);
    }
}
