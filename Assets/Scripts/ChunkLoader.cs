using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using System.IO;

public class ChunkLoader : MonoBehaviour {
    public GameObject parentsOfChunks;
    Chunk curChunk = new Chunk();

    void Start () {
        
        curChunk.SetCoord(0,0);

        curChunk.Load(parentsOfChunks);
       
	}
	
	void Update () {
	}
}
