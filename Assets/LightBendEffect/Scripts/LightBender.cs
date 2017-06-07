using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LightBender : MonoBehaviour {

    public float ExplosionSpeed = 1f; 

	IEnumerator Start () {
        var renderer = GetComponent<Renderer>();
        var material = renderer.material; // careful, this breaks batching in unity. 

        var position = 0f; 
        while(position < 1f)
        {
            yield return null; 
            position += Time.deltaTime * ExplosionSpeed;
            material.SetFloat("_Position", position); // move the material's position slider to 1 
        }

        Destroy(gameObject); // destroy self 
	}
	
}
