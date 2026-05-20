#include "metis#include#metis.h"
#include "moonbit.h"

#include <stdint.h>
#include <stdlib.h>

typedef char moonbit_metis_idx_t_must_be_i32[(sizeof(idx_t) == sizeof(int32_t)) ? 1 : -1];
typedef char moonbit_metis_real_t_must_be_f32[(sizeof(real_t) == sizeof(float)) ? 1 : -1];

typedef struct {
  int32_t status;
  int32_t *xadj;
  int32_t *adjncy;
} moonbit_metis_graph_result_t;

static void
moonbit_metis_graph_result_finalize(void *object) {
  moonbit_metis_graph_result_t *result = (moonbit_metis_graph_result_t *)object;
  if (result->xadj != NULL) {
    moonbit_decref(result->xadj);
    result->xadj = NULL;
  }
  if (result->adjncy != NULL) {
    moonbit_decref(result->adjncy);
    result->adjncy = NULL;
  }
}

static moonbit_metis_graph_result_t *
moonbit_metis_graph_result_make(int32_t status) {
  moonbit_metis_graph_result_t *result =
    (moonbit_metis_graph_result_t *)moonbit_make_external_object(
      moonbit_metis_graph_result_finalize,
      sizeof(moonbit_metis_graph_result_t)
    );
  result->status = status;
  result->xadj = NULL;
  result->adjncy = NULL;
  return result;
}

static int32_t *
moonbit_metis_copy_idx_array(const idx_t *source, int32_t length) {
  int32_t *target = moonbit_make_int32_array_raw(length);
  for (int32_t i = 0; i < length; i++) {
    target[i] = (int32_t)source[i];
  }
  return target;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_metis_version_major(void) {
  return METIS_VER_MAJOR;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_metis_version_minor(void) {
  return METIS_VER_MINOR;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_metis_version_subminor(void) {
  return METIS_VER_SUBMINOR;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_metis_noptions(void) {
  return METIS_NOPTIONS;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_metis_set_default_options(int32_t *options) {
  return METIS_SetDefaultOptions((idx_t *)options);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_metis_part_graph_kway(
  int32_t nvtxs,
  int32_t ncon,
  int32_t *xadj,
  int32_t *adjncy,
  int32_t *vwgt,
  int32_t *vsize,
  int32_t *adjwgt,
  int32_t nparts,
  float *tpwgts,
  float *ubvec,
  int32_t *options,
  int32_t *objval,
  int32_t *part
) {
  idx_t c_nvtxs = nvtxs;
  idx_t c_ncon = ncon;
  idx_t c_nparts = nparts;
  idx_t c_objval = 0;
  int status = METIS_PartGraphKway(
    &c_nvtxs,
    &c_ncon,
    (idx_t *)xadj,
    (idx_t *)adjncy,
    Moonbit_array_length(vwgt) > 0 ? (idx_t *)vwgt : NULL,
    Moonbit_array_length(vsize) > 0 ? (idx_t *)vsize : NULL,
    Moonbit_array_length(adjwgt) > 0 ? (idx_t *)adjwgt : NULL,
    &c_nparts,
    Moonbit_array_length(tpwgts) > 0 ? (real_t *)tpwgts : NULL,
    Moonbit_array_length(ubvec) > 0 ? (real_t *)ubvec : NULL,
    (idx_t *)options,
    &c_objval,
    (idx_t *)part
  );
  *objval = (int32_t)c_objval;
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_metis_part_graph_recursive(
  int32_t nvtxs,
  int32_t ncon,
  int32_t *xadj,
  int32_t *adjncy,
  int32_t *vwgt,
  int32_t *vsize,
  int32_t *adjwgt,
  int32_t nparts,
  float *tpwgts,
  float *ubvec,
  int32_t *options,
  int32_t *objval,
  int32_t *part
) {
  idx_t c_nvtxs = nvtxs;
  idx_t c_ncon = ncon;
  idx_t c_nparts = nparts;
  idx_t c_objval = 0;
  int status = METIS_PartGraphRecursive(
    &c_nvtxs,
    &c_ncon,
    (idx_t *)xadj,
    (idx_t *)adjncy,
    Moonbit_array_length(vwgt) > 0 ? (idx_t *)vwgt : NULL,
    Moonbit_array_length(vsize) > 0 ? (idx_t *)vsize : NULL,
    Moonbit_array_length(adjwgt) > 0 ? (idx_t *)adjwgt : NULL,
    &c_nparts,
    Moonbit_array_length(tpwgts) > 0 ? (real_t *)tpwgts : NULL,
    Moonbit_array_length(ubvec) > 0 ? (real_t *)ubvec : NULL,
    (idx_t *)options,
    &c_objval,
    (idx_t *)part
  );
  *objval = (int32_t)c_objval;
  return status;
}

MOONBIT_FFI_EXPORT
moonbit_metis_graph_result_t *
moonbit_metis_mesh_to_dual(
  int32_t ne,
  int32_t nn,
  int32_t *eptr,
  int32_t *eind,
  int32_t ncommon,
  int32_t numflag
) {
  idx_t c_ne = ne;
  idx_t c_nn = nn;
  idx_t c_ncommon = ncommon;
  idx_t c_numflag = numflag;
  idx_t *xadj = NULL;
  idx_t *adjncy = NULL;
  int status = METIS_MeshToDual(
    &c_ne,
    &c_nn,
    (idx_t *)eptr,
    (idx_t *)eind,
    &c_ncommon,
    &c_numflag,
    &xadj,
    &adjncy
  );
  moonbit_metis_graph_result_t *result = moonbit_metis_graph_result_make(status);
  if (status == METIS_OK) {
    int32_t xadj_len = ne + 1;
    int32_t adjncy_len = (int32_t)xadj[ne] - (numflag ? 1 : 0);
    result->xadj = moonbit_metis_copy_idx_array(xadj, xadj_len);
    result->adjncy = moonbit_metis_copy_idx_array(adjncy, adjncy_len);
    METIS_Free(xadj);
    METIS_Free(adjncy);
  }
  return result;
}

MOONBIT_FFI_EXPORT
moonbit_metis_graph_result_t *
moonbit_metis_mesh_to_nodal(
  int32_t ne,
  int32_t nn,
  int32_t *eptr,
  int32_t *eind,
  int32_t numflag
) {
  idx_t c_ne = ne;
  idx_t c_nn = nn;
  idx_t c_numflag = numflag;
  idx_t *xadj = NULL;
  idx_t *adjncy = NULL;
  int status = METIS_MeshToNodal(
    &c_ne,
    &c_nn,
    (idx_t *)eptr,
    (idx_t *)eind,
    &c_numflag,
    &xadj,
    &adjncy
  );
  moonbit_metis_graph_result_t *result = moonbit_metis_graph_result_make(status);
  if (status == METIS_OK) {
    int32_t xadj_len = nn + 1;
    int32_t adjncy_len = (int32_t)xadj[nn] - (numflag ? 1 : 0);
    result->xadj = moonbit_metis_copy_idx_array(xadj, xadj_len);
    result->adjncy = moonbit_metis_copy_idx_array(adjncy, adjncy_len);
    METIS_Free(xadj);
    METIS_Free(adjncy);
  }
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_metis_graph_result_status(moonbit_metis_graph_result_t *result) {
  return result->status;
}

MOONBIT_FFI_EXPORT
int32_t *
moonbit_metis_graph_result_xadj(moonbit_metis_graph_result_t *result) {
  moonbit_incref(result->xadj);
  return result->xadj;
}

MOONBIT_FFI_EXPORT
int32_t *
moonbit_metis_graph_result_adjncy(moonbit_metis_graph_result_t *result) {
  moonbit_incref(result->adjncy);
  return result->adjncy;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_metis_part_mesh_nodal(
  int32_t ne,
  int32_t nn,
  int32_t *eptr,
  int32_t *eind,
  int32_t *vwgt,
  int32_t *vsize,
  int32_t nparts,
  float *tpwgts,
  int32_t *options,
  int32_t *objval,
  int32_t *epart,
  int32_t *npart
) {
  idx_t c_ne = ne;
  idx_t c_nn = nn;
  idx_t c_nparts = nparts;
  idx_t c_objval = 0;
  int status = METIS_PartMeshNodal(
    &c_ne,
    &c_nn,
    (idx_t *)eptr,
    (idx_t *)eind,
    Moonbit_array_length(vwgt) > 0 ? (idx_t *)vwgt : NULL,
    Moonbit_array_length(vsize) > 0 ? (idx_t *)vsize : NULL,
    &c_nparts,
    Moonbit_array_length(tpwgts) > 0 ? (real_t *)tpwgts : NULL,
    (idx_t *)options,
    &c_objval,
    (idx_t *)epart,
    (idx_t *)npart
  );
  *objval = (int32_t)c_objval;
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_metis_part_mesh_dual(
  int32_t ne,
  int32_t nn,
  int32_t *eptr,
  int32_t *eind,
  int32_t *vwgt,
  int32_t *vsize,
  int32_t ncommon,
  int32_t nparts,
  float *tpwgts,
  int32_t *options,
  int32_t *objval,
  int32_t *epart,
  int32_t *npart
) {
  idx_t c_ne = ne;
  idx_t c_nn = nn;
  idx_t c_ncommon = ncommon;
  idx_t c_nparts = nparts;
  idx_t c_objval = 0;
  int status = METIS_PartMeshDual(
    &c_ne,
    &c_nn,
    (idx_t *)eptr,
    (idx_t *)eind,
    Moonbit_array_length(vwgt) > 0 ? (idx_t *)vwgt : NULL,
    Moonbit_array_length(vsize) > 0 ? (idx_t *)vsize : NULL,
    &c_ncommon,
    &c_nparts,
    Moonbit_array_length(tpwgts) > 0 ? (real_t *)tpwgts : NULL,
    (idx_t *)options,
    &c_objval,
    (idx_t *)epart,
    (idx_t *)npart
  );
  *objval = (int32_t)c_objval;
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_metis_node_nd(
  int32_t nvtxs,
  int32_t *xadj,
  int32_t *adjncy,
  int32_t use_vwgt,
  int32_t *vwgt,
  int32_t *options,
  int32_t *perm,
  int32_t *iperm
) {
  idx_t c_nvtxs = nvtxs;
  return METIS_NodeND(
    &c_nvtxs,
    (idx_t *)xadj,
    (idx_t *)adjncy,
    use_vwgt ? (idx_t *)vwgt : NULL,
    (idx_t *)options,
    (idx_t *)perm,
    (idx_t *)iperm
  );
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_metis_node_ndp(
  int32_t nvtxs,
  int32_t *xadj,
  int32_t *adjncy,
  int32_t use_vwgt,
  int32_t *vwgt,
  int32_t npes,
  int32_t *options,
  int32_t *perm,
  int32_t *iperm,
  int32_t *sizes
) {
  return METIS_NodeNDP(
    nvtxs,
    (idx_t *)xadj,
    (idx_t *)adjncy,
    use_vwgt ? (idx_t *)vwgt : NULL,
    npes,
    (idx_t *)options,
    (idx_t *)perm,
    (idx_t *)iperm,
    (idx_t *)sizes
  );
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_metis_compute_vertex_separator(
  int32_t nvtxs,
  int32_t *xadj,
  int32_t *adjncy,
  int32_t use_vwgt,
  int32_t *vwgt,
  int32_t *options,
  int32_t *sepsize,
  int32_t *part
) {
  idx_t c_nvtxs = nvtxs;
  idx_t c_sepsize = 0;
  int status = METIS_ComputeVertexSeparator(
    &c_nvtxs,
    (idx_t *)xadj,
    (idx_t *)adjncy,
    use_vwgt ? (idx_t *)vwgt : NULL,
    (idx_t *)options,
    &c_sepsize,
    (idx_t *)part
  );
  *sepsize = (int32_t)c_sepsize;
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_metis_node_refine(
  int32_t nvtxs,
  int32_t *xadj,
  int32_t *vwgt,
  int32_t *adjncy,
  int32_t *where,
  int32_t *hmarker,
  float ubfactor
) {
  return METIS_NodeRefine(
    nvtxs,
    (idx_t *)xadj,
    (idx_t *)vwgt,
    (idx_t *)adjncy,
    (idx_t *)where,
    (idx_t *)hmarker,
    (real_t)ubfactor
  );
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_metis_cache_friendly_reordering(
  int32_t nvtxs,
  int32_t *xadj,
  int32_t *adjncy,
  int32_t *part,
  int32_t *old2new
) {
  return METIS_CacheFriendlyReordering(
    nvtxs,
    (idx_t *)xadj,
    (idx_t *)adjncy,
    (idx_t *)part,
    (idx_t *)old2new
  );
}
