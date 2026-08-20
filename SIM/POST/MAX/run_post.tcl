#cp ../../../PNR/SS/pnr/outputs_icc2/write_data.v.gz ./
#cp ../../../STA/POST/MAX/results/TOP_max.sdf_PT ./

#vcs -full64 -debug_all 
vcs -full64 -debug_access+all -kdb -lca -cm line+tgl+assert+branch+cond+fsm \
-sdfretain \
-negdelay \
+sdfverbose \
+define+sdf_post_wst \
+neg_tchk \
+maxdelays \
+libext+.v+.vlib \
+incdir+../../TESTBENCH \
+incdir+../../../REF \
+incdir+/data/library/S28/ln28lpp_sc_9t_base_rvt_c130_V1.00c_pkg/FE-Common_sec190802_0203/MODEL \
+incdir+/data/library/S28/ln28lpp_gpio_1p8v_V1.00a_pkg/FE-Common_sec190321_0300/MODEL \
+v2k  \
-f filenames.f \
-l post_sim.log 
