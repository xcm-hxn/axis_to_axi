`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/27 11:05:04
// Design Name: 
// Module Name: axi_pkg
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


package axi_pkg;
    // AXI Transaction Burst Width.
    parameter int unsigned BurstWidth  = 32'd2;
    // AXI Transaction Response Width.
    parameter int unsigned RespWidth   = 32'd2;
    // AXI Transaction Cacheability Width.
    parameter int unsigned CacheWidth  = 32'd4;
    // AXI Transaction Protection Width.
    parameter int unsigned ProtWidth   = 32'd3;
    // AXI Transaction Quality of Service Width.
    parameter int unsigned QosWidth    = 32'd4;
    // AXI Transaction Region Width.
    parameter int unsigned RegionWidth = 32'd4;
    // AXI Transaction Length Width.
    parameter int unsigned LenWidth    = 32'd8;
    // AXI Transaction Size Width.
    parameter int unsigned SizeWidth   = 32'd3;
    // AXI Lock Width.
    parameter int unsigned LockWidth   = 32'd1;
    // AXI5 Atomic Operation Width.
    parameter int unsigned AtopWidth   = 32'd6;
    // AXI5 Non-Secure Address Identifier.
    parameter int unsigned NsaidWidth  = 32'd4;

    // AXI Transaction Burst Width.
    typedef logic [1:0]  burst_t;
    // AXI Transaction Response Type.
    typedef logic [1:0]   resp_t;
    // AXI Transaction Cacheability Type.
    typedef logic [3:0]  cache_t;
    // AXI Transaction Protection Type.
    typedef logic [2:0]   prot_t;
    // AXI Transaction Quality of Service Type.
    typedef logic [3:0]    qos_t;
    // AXI Transaction Region Type.
    typedef logic [3:0] region_t;
    // AXI Transaction Length Type.
    typedef logic [7:0]    len_t;
    // AXI Transaction Size Type.
    typedef logic [2:0]   size_t;
    // AXI5 Atomic Operation Type.
    typedef logic [5:0]   atop_t; // atomic operations
    // AXI5 Non-Secure Address Identifier.
    typedef logic [3:0]  nsaid_t;




endpackage   


  





