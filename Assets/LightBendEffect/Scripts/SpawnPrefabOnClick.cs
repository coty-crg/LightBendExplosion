using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// put this on the main camera 
[RequireComponent(typeof(Camera))]
public class SpawnPrefabOnClick : MonoBehaviour {

    public GameObject PrefabToSpawn; // drag in prefab via inspector 
    private Camera MainCam;
    
	void Start () {
        MainCam = GetComponent<Camera>(); 
	}
	
	void Update () {
        if (PrefabToSpawn == null)
            return;

        if (!Input.GetMouseButtonDown(0))
            return;

        var ray = MainCam.ScreenPointToRay(Input.mousePosition);

        RaycastHit info;

        var hitSomething = Physics.Raycast(ray, out info);
        if (!hitSomething)
            return;
        
        var spawnPos = info.point + Vector3.up;
        var spawnedObject = GameObject.Instantiate(PrefabToSpawn, spawnPos, Quaternion.LookRotation(-ray.direction, Vector3.up)); 
	}
}
