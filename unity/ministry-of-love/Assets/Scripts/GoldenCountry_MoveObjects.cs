using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GoldenCountry_MoveObjects : MonoBehaviour
{
    private int numChildren;
    private bool[] initChildren;
    private Vector3[] initChildrenPos;
    private int childIter;
    public float spawnRate = 1.0f;
    public bool stop = false;
    private float nextSpawn = 0.0f;


    // Start is called before the first frame update
    void Start()
    {
        numChildren = this.transform.childCount;
        initChildren = new bool[numChildren];
        initChildrenPos = new Vector3[numChildren];
        for(int i = 0; i < numChildren; i++) {
          initChildren[i] = false;
          initChildrenPos[i] = this.gameObject.transform.GetChild(i).gameObject.transform.localPosition;
        }
        childIter = 0;
    }

    // Update is called once per frame
    void Update()
    {
        if(Time.time > nextSpawn && !stop) {
          nextSpawn = Time.time + spawnRate;
          if(childIter < numChildren-1) childIter++;
          else childIter = 0;
          initChildren[childIter] = true;
          Debug.Log(childIter);
        }

        for(int i = 0; i < numChildren; i++) {
          if(initChildren[i]) {
            GameObject child = this.gameObject.transform.GetChild(i).gameObject;
            child.transform.Translate(new Vector3(0.0f, 0.05f, 0.0f));
            if(child.transform.localPosition.y >= 40.0f) {
              initChildren[i] = false;
              child.transform.localPosition = initChildrenPos[i];
            }
          }
        }
    }
}
