using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class Actuate : MonoBehaviour {

	public GameObject cube;
	public float elapsedTime;
	public float yScale = 12.0f;
	public float noiseOffset = 0.1f;
	public float timeScale = 0.5f;
	private GameObject[] clones;
	private int w, h;

	// Use this for initialization
	void Start () {
		clones = new GameObject[120];
		w = 12;
		h = 10;
		for (int z = 0; z < h; z++) {
			for (int x = 0; x < w; x++) {
				int index = z * w + x;
				clones[index] = Instantiate(cube, new Vector3(x, 0, z), Quaternion.identity);
				clones[index].transform.localScale = new Vector3 (1.0f, 2.0f, 1.0f);
			}
		}
	}
	
	// Update is called once per frame
	void Update () {
		elapsedTime = Time.time*timeScale;
		for (int z = 0; z < h; z++) {
			for (int x = 0; x < w; x++) {
				int index = z * w + x;
				clones [index].transform.localScale = new Vector3 (1.0f, Perlin.Noise(x*noiseOffset, z*noiseOffset, elapsedTime) * yScale + 2.0f, 1.0f);
			}
		}
	}
}
