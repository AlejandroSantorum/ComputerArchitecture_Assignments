#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>

#include "arqo3.h"

tipo** compute_transMatrix_mult(tipo **m1, tipo **m2, int n);

int main(int argc, char **argv){
	int n;
	tipo **m1=NULL;
	tipo **m2=NULL;
	tipo **res=NULL;
	struct timeval fin,ini;

	printf("Word size: %ld bits\n",8*sizeof(tipo));

	if(argc!=2){
		printf("Error: ./%s <matrix size>\n", argv[0]);
		return -1;
	}
	n = atoi(argv[1]);

	m1 = generateMatrix(n);
	if(!m1){
		printf("ERROR: unable to allocate memory for matrix 1\n");
		return -1;
	}
	m2 = generateMatrix(n);
	if(!m2){
		printf("ERROR: unable to allocate memory for matrix 2\n");
		return -1;
	}

	gettimeofday(&ini,NULL);
	/* Main computation */
	res = compute_transMatrix_mult(m1, m2, n);
	/* End of computation */
	gettimeofday(&fin,NULL);
	if(!res){
		printf("ERROR: unable to compute the matrix multiplication of size %d.\n", n);
		return -1;
	}

	printf("Execution time: %f\n", ((fin.tv_sec*1000000+fin.tv_usec)-(ini.tv_sec*1000000+ini.tv_usec))*1.0/1000000.0);

	freeMatrix(m1);
	freeMatrix(m2);
	freeMatrix(res);
	return 0;

}

tipo** compute_transMatrix_mult(tipo **m1, tipo **m2, int n){
	tipo **res=NULL;
	tipo aux;
	int i,j,k;

	res = generateEmptyMatrix(n);
	if(!res){
		return NULL;
	}

	for(i=0; i<n; i++){
		for(j=0; j<n; j++){
			aux = 0;
			for(k=0; k<n; k++){
				aux += m1[i][k]*m2[j][k];
			}
			res[i][j] = aux;
		}
	}
	return res;
}