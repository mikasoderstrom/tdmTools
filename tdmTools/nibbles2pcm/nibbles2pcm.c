#include <stdio.h>
#include <stdint.h>

struct InterleavedBits_t {
  uint32_t WS_num;
  uint32_t nibbles[6];
  uint16_t scaler;
  uint16_t mic;
};

struct SampleRound_t
{
  struct InterleavedBits_t samples[8];
};
//struct PCMs {
  
int fileSize;

int main( int argc, char *argv[] )
{
  FILE *fp, *rfp;
  struct SampleRound_t sampleRound;
  int simulSamps[64];
  int i, j, k, l, p;

  if( 3 != argc )
    {
      printf("Expecting two arguments!\n");
      return 1;
    }

  fp = fopen(argv[1], "r");
  if (NULL == fp)
    {
      printf("Could not open input file \"%s\"\n", argv[1]);
      return 1;
    }

  rfp = fopen(argv[2], "w");
  if (NULL == rfp)
    {
      printf("Could not open result-file \"%s\"\n", argv[1]);
      return 1;
    }

  fseek(fp, 0L, SEEK_END);
  fileSize = ftell(fp);
  rewind(fp);

  int numOfWS = (fileSize/sizeof(struct SampleRound_t));
  
  printf("Size: 0x%x\t0x%x\n", fileSize, (unsigned int)numOfWS);
  
  for (i=0; i<numOfWS; i++)
    {
      uint32_t PCM[4];
      
      fread(&sampleRound, sizeof(sampleRound), 1, fp);
      struct InterleavedBits_t* interleavedBits_p = &sampleRound.samples[0];
      uint32_t WS_num = interleavedBits_p->WS_num;
      uint32_t fs = 25000000 / 512 / (interleavedBits_p->scaler + 1);
      fprintf(rfp, "%5d, %8d", fs, WS_num);
      
      for (l=0; l<8; l++)
	{
	  int WS_numIter;
	  interleavedBits_p = &sampleRound.samples[l];
	  WS_numIter = interleavedBits_p->WS_num;
	  if (WS_num != WS_numIter)
	    {
	      printf("Format error: Change of WS_num at %d\n", WS_num);
	      return 1;
	    }
	  
	  //printf("mic=%02d ", interleavedBits_p->mic);
	  for (int z=0; z<4; z++)
	    {
	      PCM[z] = 0;
	    }

	  for (j=0; j < 3; j++)
	    {
	      for (k=28; k >= 0; k -= 4)
		{
		  unsigned int nibble = (interleavedBits_p->nibbles[j]>>k)&0xf;
		  for (int ii = 0; ii < 4; ii++)
		    {
		      const int powers[] = {1, 2, 4, 8};
		      int bit = (nibble&(powers[ii]));
		      PCM[ii] *= 2;
		      PCM[ii] |= bit >> ii;
		    }
		}
	    }

	  for (int z=0; z<4; z++)
	    {
	      int32_t val = PCM[z];
	      if (0x800000 == (val & 0x800000))
		{
		  val |= 0xffff000000;
		}
	      simulSamps[z*16+l*2] = val;

	      /* fprintf(rfp, ", %9d", val); */
	    }


	  for (int z=0; z<4; z++)
	    {
	      PCM[z] = 0;
	    }

	  for (j=3; j < 6; j++)
	    {
	      for (k=28; k >= 0; k -= 4)
		{
		  unsigned int nibble = (interleavedBits_p->nibbles[j]>>k)&0xf;
		  for (int ii = 0; ii < 4; ii++)
		    {
		      const int powers[] = {1, 2, 4, 8};
		      int bit = (nibble&(powers[ii]));
		      PCM[ii] *= 2;
		      PCM[ii] |= bit >> ii;
		    }
		}
	    }

	  for (int z=0; z<4; z++)
	    {
	      int32_t val = PCM[z];
	      if (0x800000 == (val & 0x800000))
		{
		  val |= 0xffff000000;
		}
	      simulSamps[z*16+l*2+1] = val;

	      /* fprintf(rfp, ", %9d", val); */
	    }
	}
      for (p = 0; p < 64; p++)
	{
	  fprintf(rfp, ", %9d", simulSamps[p]);
	}
      fprintf(rfp, "\n");
    }

  fclose(rfp);
  printf("created file %s\n", argv[2]);
  return 0;

}
