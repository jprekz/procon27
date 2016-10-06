module projection;

import imagetovec.type;

struct ProjParams {
    double A, B, C, D, E, F, G, H;
}

ProjParams calcProjParams(double[2][4] naOrig, double[2][4] naTran) {
    ProjParams d;
    double[8][8] dATA;

    dATA[0][0] =                 naOrig[0][0];
    dATA[0][1] =                 naOrig[0][1];
    dATA[0][2] =                            1;
    dATA[0][3] =                            0;
    dATA[0][4] =                            0;
    dATA[0][5] =                            0;
    dATA[0][6] = -1*naTran[0][0]*naOrig[0][0];
    dATA[0][7] = -1*naTran[0][0]*naOrig[0][1];
    dATA[1][0] =                 naOrig[1][0];
    dATA[1][1] =                 naOrig[1][1];
    dATA[1][2] =                            1;
    dATA[1][3] =                            0;
    dATA[1][4] =                            0;
    dATA[1][5] =                            0;
    dATA[1][6] = -1*naTran[1][0]*naOrig[1][0];
    dATA[1][7] = -1*naTran[1][0]*naOrig[1][1];
    dATA[2][0] =                 naOrig[2][0];
    dATA[2][1] =                 naOrig[2][1];
    dATA[2][2] =                            1;
    dATA[2][3] =                            0;
    dATA[2][4] =                            0;
    dATA[2][5] =                            0;
    dATA[2][6] = -1*naTran[2][0]*naOrig[2][0];
    dATA[2][7] = -1*naTran[2][0]*naOrig[2][1];
    dATA[3][0] =                 naOrig[3][0];
    dATA[3][1] =                 naOrig[3][1];
    dATA[3][2] =                            1;
    dATA[3][3] =                            0;
    dATA[3][4] =                            0;
    dATA[3][5] =                            0;
    dATA[3][6] = -1*naTran[3][0]*naOrig[3][0];
    dATA[3][7] = -1*naTran[3][0]*naOrig[3][1];
    dATA[4][0] =                            0;
    dATA[4][1] =                            0;
    dATA[4][2] =                            0;
    dATA[4][3] =                 naOrig[0][0];
    dATA[4][4] =                 naOrig[0][1];
    dATA[4][5] =                            1;
    dATA[4][6] = -1*naTran[0][1]*naOrig[0][0];
    dATA[4][7] = -1*naTran[0][1]*naOrig[0][1];
    dATA[5][0] =                            0;
    dATA[5][1] =                            0;
    dATA[5][2] =                            0;
    dATA[5][3] =                 naOrig[1][0];
    dATA[5][4] =                 naOrig[1][1];
    dATA[5][5] =                            1;
    dATA[5][6] = -1*naTran[1][1]*naOrig[1][0];
    dATA[5][7] = -1*naTran[1][1]*naOrig[1][1];
    dATA[6][0] =                            0;
    dATA[6][1] =                            0;
    dATA[6][2] =                            0;
    dATA[6][3] =                 naOrig[2][0];
    dATA[6][4] =                 naOrig[2][1];
    dATA[6][5] =                            1;
    dATA[6][6] = -1*naTran[2][1]*naOrig[2][0];
    dATA[6][7] = -1*naTran[2][1]*naOrig[2][1];
    dATA[7][0] =                            0;
    dATA[7][1] =                            0;
    dATA[7][2] =                            0;
    dATA[7][3] =                 naOrig[3][0];
    dATA[7][4] =                 naOrig[3][1];
    dATA[7][5] =                            1;
    dATA[7][6] = -1*naTran[3][1]*naOrig[3][0];
    dATA[7][7] = -1*naTran[3][1]*naOrig[3][1];

    double[8][8] dATA_I = matinv(dATA);

    d.A = dATA_I[0][0]*naTran[0][0] + dATA_I[0][1]*naTran[1][0] + 
          dATA_I[0][2]*naTran[2][0] + dATA_I[0][3]*naTran[3][0] + 
          dATA_I[0][4]*naTran[0][1] + dATA_I[0][5]*naTran[1][1] + 
          dATA_I[0][6]*naTran[2][1] + dATA_I[0][7]*naTran[3][1];
    d.B = dATA_I[1][0]*naTran[0][0] + dATA_I[1][1]*naTran[1][0] + 
          dATA_I[1][2]*naTran[2][0] + dATA_I[1][3]*naTran[3][0] + 
          dATA_I[1][4]*naTran[0][1] + dATA_I[1][5]*naTran[1][1] + 
          dATA_I[1][6]*naTran[2][1] + dATA_I[1][7]*naTran[3][1];
    d.C = dATA_I[2][0]*naTran[0][0] + dATA_I[2][1]*naTran[1][0] + 
          dATA_I[2][2]*naTran[2][0] + dATA_I[2][3]*naTran[3][0] + 
          dATA_I[2][4]*naTran[0][1] + dATA_I[2][5]*naTran[1][1] + 
          dATA_I[2][6]*naTran[2][1] + dATA_I[2][7]*naTran[3][1];
    d.D = dATA_I[3][0]*naTran[0][0] + dATA_I[3][1]*naTran[1][0] + 
          dATA_I[3][2]*naTran[2][0] + dATA_I[3][3]*naTran[3][0] + 
          dATA_I[3][4]*naTran[0][1] + dATA_I[3][5]*naTran[1][1] + 
          dATA_I[3][6]*naTran[2][1] + dATA_I[3][7]*naTran[3][1];
    d.E = dATA_I[4][0]*naTran[0][0] + dATA_I[4][1]*naTran[1][0] + 
          dATA_I[4][2]*naTran[2][0] + dATA_I[4][3]*naTran[3][0] + 
          dATA_I[4][4]*naTran[0][1] + dATA_I[4][5]*naTran[1][1] + 
          dATA_I[4][6]*naTran[2][1] + dATA_I[4][7]*naTran[3][1];
    d.F = dATA_I[5][0]*naTran[0][0] + dATA_I[5][1]*naTran[1][0] + 
          dATA_I[5][2]*naTran[2][0] + dATA_I[5][3]*naTran[3][0] + 
          dATA_I[5][4]*naTran[0][1] + dATA_I[5][5]*naTran[1][1] + 
          dATA_I[5][6]*naTran[2][1] + dATA_I[5][7]*naTran[3][1];
    d.G = dATA_I[6][0]*naTran[0][0] + dATA_I[6][1]*naTran[1][0] + 
          dATA_I[6][2]*naTran[2][0] + dATA_I[6][3]*naTran[3][0] + 
          dATA_I[6][4]*naTran[0][1] + dATA_I[6][5]*naTran[1][1] + 
          dATA_I[6][6]*naTran[2][1] + dATA_I[6][7]*naTran[3][1];
    d.H = dATA_I[7][0]*naTran[0][0] + dATA_I[7][1]*naTran[1][0] + 
          dATA_I[7][2]*naTran[2][0] + dATA_I[7][3]*naTran[3][0] + 
          dATA_I[7][4]*naTran[0][1] + dATA_I[7][5]*naTran[1][1] + 
          dATA_I[7][6]*naTran[2][1] + dATA_I[7][7]*naTran[3][1];

    return d;
}

double[8][8] matinv(double[8][8] mat) {
    enum N = 8;

    double[N * 2][N] M;
    foreach(i, r; mat) {
        double[N] e;
        foreach(j, ref y; e) {
            y = (i == j) ? 1 : 0;
        }
        M[i] = r ~ e;
    }

    foreach(i; 0 .. N) {
        foreach(k; i .. N) {
            const pivot = M[k][i];
            if (pivot == 0.0) continue;
            if (k != i) {
                auto buf = M[k];
                M[k] = M[i];
                M[i] = buf;
            }
            
            foreach(j; 0 .. N * 2) {
                M[i][j] = (1 / pivot) * M[i][j];
            }
        }
    
        foreach(k; 0 .. N) {
            if (i == k) continue;
            const mul = M[k][i];
            foreach(n; i .. N * 2) {
                M[k][n] -= mul * M[i][n];
            }
        }
    }

    double[N][N] O;
    foreach(i; 0 .. N) foreach(j; 0 .. N) {
        O[i][j] = M[i][j + N];
    }
    return O;
}

Vec!double projectionTrans(Vec!double nOrig, ProjParams d) {
    return Vec!double(
        (nOrig.x * d.A + nOrig.y * d.B + d.C) / (nOrig.x * d.G + nOrig.y * d.H + 1),
        (nOrig.x * d.D + nOrig.y * d.E + d.F) / (nOrig.x * d.G + nOrig.y * d.H + 1)
    );
}
