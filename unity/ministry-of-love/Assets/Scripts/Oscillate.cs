using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Oscillate : MonoBehaviour {

	public float timeOffset;

	// Use this for initialization
	void Start () {
//		transform.localPosition = new Vector3 (1.0f, -1.0f, 1.0f);
		transform.localScale = new Vector3 (1.5f, 1.0f, 1.5f);
	}
	
	// Update is called once per frame
	void Update () {
		float delta = 0.2f * Mathf.Sin (0.1f * Time.frameCount + timeOffset);
		transform.localScale += new Vector3 (0.0f, delta, 0.0f);
		Debug.Log (transform.localScale.y);
	}
}
