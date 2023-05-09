# Multi-part Match

Javinizer supports sorting multi-part videos. When sorted, all multi-part videos will be renamed in the format: `ID-###-pt#`.

The following filename formats will be detected as a multi-part video.

| FIlename Format  | Example                    |
| ---------------- | -------------------------- |
| ID-###\[a-iA-I]  | ID-030A, ID-030B           |
| ID-###-\[a-iA-I] | ID-030-A, ID-030B          |
| ID-###-\d        | ID-030-1, ID-030-2         |
| ID-###-0\d       | ID-030-01, ID-030-02       |
| ID-###-00\d      | ID-030-001, ID-030-002     |
| ID-###-pt\d      | ID-030-pt1, ID-030-pt2     |
| ID-### - pt\d    | ID-030 - pt1, ID-030 - pt2 |
| ID-###-part\d    | ID-030-part1, ID-030-part2 |
| ID-###\_\d       | ID-030\_1, ID-030\_2       |
| ID-###\_0\d      | ID-030\_01, ID-030\_02     |
| ID-###-cd\d      | ID-030-cd1, ID-030-cd2     |
